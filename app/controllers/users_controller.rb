class UsersController < ApplicationController
  skip_before_action :logged_in_user, only: [:new, :create, :record_audio]

  require 'bundler/setup'
  require 'pocketsphinx-ruby'
  require 'chromaprint'
  require 'json'
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


  def record_audio

    @match = false

    if params[:flag]
      flag = params[:flag]
    else
      flag = 1
    end

    puts 'flag is :' + flag.to_s
    if flag == 1
      @user = User.new(user_params)
      @user.save
      puts 'user saved'
      puts 'user id is:' + @user.id.to_s
    else
      puts 'looking for user: ' + params[:user_name]
      @user = User.find_by username: params[:user_name]
      puts @user
    end

    logger.debug "Recording #{RECORDING_LENGTH} seconds of audio..."
    microphone = Microphone.new

    filename = "test_write_user_id_"+ @user.username.to_s + ".raw"

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
    if @decoded_text == @user.passphrase_text
      puts 'user is ' + @user.username
      @user.update_attribute(:passphrase_recording, filename)
      audio_fingerprint_json = { :data => audio_fingerprint }.to_json
      @user.update_attribute(:passphrase_fingerprint, audio_fingerprint_json)
      @match = true
    end
  end

  private
    def user_params
      params.require(:user).permit(:username,:password,:password_confirmation, :passphrase_text, :passphrase_recording, :passphrase_fingerprint)
    end
end
