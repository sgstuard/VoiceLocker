class SessionsController < ApplicationController

  require 'bundler/setup'
  require 'pocketsphinx-ruby'
  include Pocketsphinx

  MAX_SAMPLES = 2048
  RECORDING_INTERVAL = 0.1
  RECORDING_LENGTH = 5

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
    decoder.decode filename
    decoded_text = decoder.hypothesis.to_s

    puts 'user tried logging in with: ' + decoded_text
    if decoded_text == user.passphrase_text
      puts 'user is ' + user.username
      match_login = true
    end


    if user && user.authenticate(params[:session][:password]) && match_login
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
