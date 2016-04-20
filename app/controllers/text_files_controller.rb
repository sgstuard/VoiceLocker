class TextFilesController < ApplicationController
  before_action :correct_user, except: [:index, :create, :new]

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

  def index
    @text_files = TextFile.all
  end

  def new
    @text_file = TextFile.new
  end

  #show the text file
  def show
    @text_file = TextFile.find(params[:id])
    user_key = get_phrase_for_encryption @text_file
    if !user_key
      redirect_to user_files_path and return
    end
    @decrypted_title = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/dec.py '#{@text_file.title}' #{user_key}`
    @decrypted_text = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/dec.py '#{@text_file.text}' #{user_key}`

    puts 'showing title: ' + @decrypted_text

  end

  #method to take you to edit text file
  def edit
    @text_file = TextFile.find(params[:id])
    user_key = get_phrase_for_encryption @text_file
    if !user_key
      flash.now[:danger] = 'Cannot edit file. Your voice did not match your passphrase, try again.'
      redirect_to user_files_path and return
    else
    @decrypted_title = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/dec.py '#{@text_file.title}' #{user_key}`
    @decrypted_text = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/dec.py '#{@text_file.text}' #{user_key}`

    puts 'showing title: ' + @decrypted_text
    end
  end

  #creates text file
  def create
  @text_file = TextFile.new(file_params)
  user_key = get_phrase_for_encryption @text_file
  if !user_key
    flash.now[:danger] = 'Cannot save file. Your voice did not match your passphrase, try again.'
    redirect_to user_files_path and return
    flash.now[:danger] = 'Cannot save file. Your voice did not match your passphrase, try again.'

  else
  encrypted_title = `python lib/assets/python/enc.py '#{@text_file.title}' #{user_key}`
  encrypted_data = `python lib/assets/python/enc.py '#{@text_file.text}' #{user_key}`
  @text_file.title = encrypted_title
  @text_file.text = encrypted_data
    if @text_file.save
      redirect_to user_files_path
    else
      flash.now[:danger] = 'Cannot save file. Your voice did not match your passphrase, try again.'
      render 'new'
    end
  end
  end

  #updates text file
  def update
    @text_file = TextFile.find(params[:id])
    user_key = get_phrase_for_encryption @text_file
    if !user_key
      'Cannot update. Your voice did not match your passphrase, try again.'
      redirect_to user_files_path and return
    else
    encrypted_title = `python lib/assets/python/enc.py '#{@text_file.title}' #{user_key}`
    encrypted_data = `python lib/assets/python/enc.py '#{@text_file.text}' #{user_key}`
    @text_file.title = encrypted_title
    @text_file.text = encrypted_data
    puts @text_file.title
    puts encrypted_title
    if @text_file.update(file_params)
      @text_file.title = encrypted_title
      @text_file.text = encrypted_data
      @text_file.save
      redirect_to @text_file
    else
      render 'edit'
    end
    end

  end

  #deletes text file
  def destroy
    @text_file = TextFile.find(params[:id])
    user_key = get_phrase_for_encryption @text_file
    if !user_key
      'Cannot delete. Your voice did not match your passphrase, try again.'
      redirect_to user_files_path and return
    else

    @text_file.destroy
    redirect_to user_files_path
    end

  end

  private
  def file_params
    params.require(:text_file).permit(:title, :text, :user_id)
  end
  def hash_passphrase_text passphrase
    passphrase_text_hash = Digest::SHA256.base64digest passphrase
  end

  def generate_hash_24 phrase, username
    passphrase_hash = Digest::SHA256.base64digest phrase+username
    key = passphrase_hash[0,24]
    puts 'size in bytes is: ' + key.bytesize.to_s
    return key
  end

  #false is returned if the hash of the decoded text from speech does not match the user's passphrase hash in the db
  def get_phrase_for_encryption text_file
    user = User.find(text_file.user_id)

    logger.debug "Recording #{RECORDING_LENGTH} seconds of audio... to login"
    microphone = Microphone.new
    filename = "test_write_user_id_"+ user.username.to_s + "_create_file.raw"

    #writes to file to check against passphrase and fingerprnt
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

    #decode the speech heard
    decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
    #decoder.decode filename
    decoder.decode filename
    decoded_text = decoder.hypothesis.to_s

    #16000 sampling rate, 1 (mono) channel, read fingerprint of file recorded by pocketsphinx
    user_audio_context = Chromaprint::Context.new(16000, 1)
    audio_data = File.binread(filename)
    #audio_data = File.binread(filename)
    audio_fingerprint = user_audio_context.get_fingerprint(audio_data)
    puts audio_fingerprint.compressed
    threshold = 0.50


    puts 'user tried validating with: ' + decoded_text
    #hash the passphrase to see if it matches stored in db
    voice_to_pass_hash = hash_passphrase_text decoded_text
    if voice_to_pass_hash == user.passphrase_text #this means the words are the same
      #hash the passphrase for the key
      login_hash_key = generate_hash_24 decoded_text, user.username
      encrypted_fingerprint = user.passphrase_fingerprint
      puts 'the users fingerprint is : ' + encrypted_fingerprint
      decrypted = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/dec.py '#{encrypted_fingerprint}' #{login_hash_key}`
      puts decrypted
      decrypted_json = JSON.parse(decrypted)

      newone = Chromaprint::Fingerprint.new(decrypted_json["compressed"], decrypted_json["raw"])
      puts newone.compare(audio_fingerprint).to_s
      if audio_fingerprint.compare(newone) > threshold
        return login_hash_key
      else
        return false
        flash.now[:danger] = 'Your voice did not match the fingerprint, try again.'
        redirect_to user_files_path
      end


    else
      return false
      flash.now[:danger] = 'Your voice did not match passphrase, try again.'
    end

  end

  #for testing, before users could see all files
  def correct_user
    file = TextFile.find(params[:id])
    if(file.user_id != current_user.id)
      flash[:danger] = "That file does not belong to you!"
      redirect_to user_files_url
    end
  end

end
