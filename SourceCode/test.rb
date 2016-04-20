require 'json'
require 'digest'
require 'chromaprint'
include Chromaprint

def generate_hash_24 phrase, username
  passphrase_hash = Digest::SHA256.base64digest phrase+username
  key = passphrase_hash[0,24]
  puts key
  puts 'size in bytes is: ' + key.bytesize.to_s
  return key
end
private def hash_passphrase_text passphrase
  passphrase_text_hash = Digest::SHA256.base64digest passphrase
end

key = generate_hash_24 "black xylophone cat crocodile", "testing"
puts key
pass_key = hash_passphrase_text "black xylophone cat crocodile"
puts pass_key
user_audio_context = Chromaprint::Context.new(16000, 1)
audio_data = File.binread("/home/simon/Development/VoiceLocker/voicelocker/test_write_user_id_testing_login_success.raw")
audio_fingerprint = user_audio_context.get_fingerprint(audio_data)
jason = { :compressed => audio_fingerprint.compressed, :raw => audio_fingerprint.raw }.to_json
puts jason
encrypted_fingerprint = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/enc.py '#{jason}' #{key}`
puts encrypted_fingerprint

decrypted_fingerprint = `python /home/simon/Development/VoiceLocker/voicelocker/lib/assets/python/dec.py '#{encrypted_fingerprint}' #{key}`
decrypted_fingerprint = JSON.parse(decrypted_fingerprint)
puts decrypted_fingerprint

newone = Chromaprint::Fingerprint.new(decrypted_fingerprint["compressed"], decrypted_fingerprint["raw"])
puts 'the compressed is ' + newone.compressed.to_s