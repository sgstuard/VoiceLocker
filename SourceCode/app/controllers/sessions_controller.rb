# File and first and last lines created by Rails. All other code ours.
# Contributors: Simon Stuard, Alex Humphries

class SessionsController < ApplicationController
  skip_before_action :logged_in_user

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

  private def hash_passphrase_text passphrase
    passphrase_text_hash = Digest::SHA256.base64digest passphrase
  end

  private def generate_hash_24 phrase, username
    passphrase_hash = Digest::SHA256.base64digest phrase+username
    key = passphrase_hash[0,24]
    puts 'size in bytes is: ' + key.bytesize.to_s
    return key
  end

  #creates a session from a user login
  def create
    user = User.find_by(username: params[:session][:username])

    match_login = false
    logger.debug "Recording #{RECORDING_LENGTH} seconds of audio... to login"
    microphone = Microphone.new
    filename = "test_write_user_id_"+ user.username.to_s + "_login.raw"


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

    decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
    #decoder.decode filename
    decoder.decode filename
    decoded_text = decoder.hypothesis.to_s

    #16000 sampling rate, 1 channel
    user_audio_context = Chromaprint::Context.new(16000, 1)
    audio_data = File.binread(filename)
    #audio_data = File.binread(filename)
    audio_fingerprint = user_audio_context.get_fingerprint(audio_data)
    puts audio_fingerprint.compressed
    threshold = 0.50


    puts 'user tried logging in with: ' + decoded_text
    #hash the passphrase to see if it matches stored in db
    voice_to_pass_hash = hash_passphrase_text decoded_text
    if voice_to_pass_hash == user.passphrase_text #this means the words are the same
      #hash the passphrase for the key
      login_hash_key = generate_hash_24 decoded_text, user.username
      #use the hash to decrypt the fingerprint

      #testing purposes only, user tester and password thisisatest
      #decrypt fingerprint in db to check
      encrypted_fingerprint = user.passphrase_fingerprint
      puts 'the users fingerprint is : ' + encrypted_fingerprint
      decrypted = `python lib/assets/python/dec.py '#{encrypted_fingerprint}' #{login_hash_key}`
      puts decrypted
      decrypted_json = JSON.parse(decrypted)

      newone = Chromaprint::Fingerprint.new(decrypted_json["compressed"], decrypted_json["raw"])
      puts decrypted_json

      puts 'user passphrase hash matches ' + user.username
      #puts audio_fingerprint.compare(audio_data_check_finger)
      puts audio_fingerprint.compare(newone)
      #compare the stored fingerprint to the newly recorded fingerprint on login
      if audio_fingerprint.compare(newone) >= threshold
        #if the fingerprints match to a degree above or the same as threshold, login
        match_login = true
        puts threshold.to_s
        @threshold_level = audio_fingerprint.compare(newone)
      end

    end

    #validate user exists and their parameters are correct, log them in
    if user && match_login
      log_in user
      redirect_to user_files_path
    else
      flash.now[:danger] = 'Invalid username/password/passphrase combination'
      render 'new'
    end
  end

  def new
  end

  def destroy
    log_out
    redirect_to root_url
  end

  #just for testing
  def record_audio

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

    decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
    decoder.decode filename
    @decoded_text = decoder.hypothesis.to_s
    puts 'printing the word'
    puts @decoded_text
    if @decoded_text == @user.passphrase_text
      puts 'user is ' + @user.username
      @user.update_attribute(:passphrase_recording, filename)
      @match = true
    end
  end
end
