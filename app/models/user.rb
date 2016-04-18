class User < ActiveRecord::Base
	validates :username, 	presence: true, length: {minimum: 6, maximum: 20}, 
							uniqueness: true
	has_secure_password
	validates :password,	presence: true, length: {minimum: 6}
	validates_length_of :passphrase_text, :minimum => 1, :too_short => "Your passphrase must be 4 words long.", :tokenizer => lambda {|str| str.scan(/\w+/) }
end
