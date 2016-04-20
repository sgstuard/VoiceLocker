require 'digest'
hash = Digest::SHA256.base64digest 'test string'

# Need to take first 24bytes (32characters)
key = hash[0,32]
puts key.length
