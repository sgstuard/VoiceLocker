class UsersController < ApplicationController

  require 'bundler/setup'
  require 'pocketsphinx-ruby'
  include Pocketsphinx

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
    flash[:success] = "Lets record audio"
    sleep(3)

  end

  def record_audio_method
    logger.debug "Recording #{RECORDING_LENGTH} seconds of audio..."
    microphone = Microphone.new

    File.open("test_write.raw", "wb") do |file|
      logger.debug('recording now')

      microphone.record do

        FFI::MemoryPointer.new(:int16, MAX_SAMPLES) do |buffer|
          puts 'recording now'

          50.times do
            sample_count = microphone.read_audio(buffer, MAX_SAMPLES)

            # sample_count * 2 since this is length in bytes
            file.write buffer.get_bytes(0, sample_count * 2)

            sleep RECORDING_INTERVAL
          end
        end
      end
    end

    decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
    decoder.decode 'test_write.raw'
    @decoded_text = decoder.hypothesis.to_s
    puts 'printing the word'
    puts @decoded_text
  end

  private
    def user_params
      params.require(:user).permit(:username,:password,:password_confirmation, :passphrase_text, :passphrase_audio)
    end
end
