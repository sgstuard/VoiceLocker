class UsersController < ApplicationController
  skip_before_action :logged_in_user, only: [:new, :create, :record_audio]

  require 'bundler/setup'
  require 'pocketsphinx-ruby'
  require 'chromaprint'
  require 'json'
  require 'digest'
  include Pocketsphinx
  include Chromaprint

  MAX_SAMPLES = 2048
  RECORDING_INTERVAL = 0.1
  RECORDING_LENGTH = 5

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to VoiceLocker!"
      redirect_to user_files_path
    else
      render 'new'
    end
  end

  #handles user signup and initial fingerprint recording
  def record_audio

    @match = false

    if params[:flag]
      flag = params[:flag]
    else
      flag = 1
    end

    puts 'flag is :' + flag.to_s
    #flag 1 means this is the first time the user will say their phrase
    if flag == 1
      @user = User.new(user_params)
      @plain_passphrase = @user.passphrase_text
      @user.passphrase_text = hash_passphrase_text @plain_passphrase
      @user.save
      puts 'user saved'
      puts 'plain passphrase is: ' + @plain_passphrase
      puts 'hashed passphrase is: ' + @user.passphrase_text
      puts 'user id is:' + @user.id.to_s

    else
      #the else handles when the users phrase didn't match decoded text, so they redo the recording without changing user
      puts 'looking for user: ' + params[:user_name]
      @plain_passphrase = params[:plain_phrase]
      puts 'user passphrase is: ' + @plain_passphrase
      @user = User.find_by username: params[:user_name]
      @user.save
      puts @user.username
    end

    logger.debug "Recording #{RECORDING_LENGTH} seconds of audio..."
    microphone = Microphone.new

    filename = "test_write_user_id_"+ @user.username.to_s + "_signup.raw"

    File.open(filename, "wb") do |file|
      logger.debug('recording now')

      microphone.record do

        FFI::MemoryPointer.new(:int16, MAX_SAMPLES) do |buffer|
          puts 'recording now'

          30.times do
            sample_count = microphone.read_audio(buffer, MAX_SAMPLES)

            # sample_count * 2 since this is length in bytes
            file.write buffer.get_bytes(0, sample_count * 2)

            sleep RECORDING_INTERVAL
          end
        end
      end
    end

    #16000 sampling rate, 1 channel
    user_audio_context = Chromaprint::Context.new(16000, 1)
    audio_data = File.binread(filename)
    audio_fingerprint = user_audio_context.get_fingerprint(audio_data)
    puts audio_fingerprint.compressed

    decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
    decoder.decode filename
    @decoded_text = decoder.hypothesis.to_s
    puts 'printing the word'
    puts @decoded_text
    #if @decoded_text == @plain_passphrase PUT THIS BACK AFTER ENCRYPT TEST
    if hash_passphrase_text(@decoded_text) == @user.passphrase_text
      puts 'user is ' + @user.username

      #now we encrypt the fingerprint
      #generate key for the user based on passphrase
      key = generate_hash_24 @plain_passphrase, @user.username
      puts 'passphrase passed to python: ' + @plain_passphrase
      @user.update_attribute(:passphrase_recording, filename)
      finger_json = { :compressed => audio_fingerprint.compressed, :raw => audio_fingerprint.raw }.to_json
      encrypted_fingerprint = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/enc.py '#{finger_json}' #{key}`
      @user.update_attribute(:passphrase_fingerprint, encrypted_fingerprint)
      @match = true

    else
      @match = false

    end


  end

  private
    def user_params
      params.require(:user).permit(:username,:password,:password_confirmation, :passphrase_text, :passphrase_recording, :passphrase_fingerprint)
    end

    #computes hash of decoded passphrase to verify user (1st factor auth)
    def hash_passphrase_text passphrase
    passphrase_text_hash = Digest::SHA256.base64digest passphrase
    end

    #generate the key to use in the 3DES encrypt/decrypt
    def generate_hash_24 phrase, username
      passphrase_hash = Digest::SHA256.base64digest phrase+username
      key = passphrase_hash[0,24]
      puts 'size in bytes is: ' + key.bytesize.to_s
      return key
    end

end
