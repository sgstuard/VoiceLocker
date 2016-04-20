class User < ActiveRecord::Base
  validates :username,  presence: true, length: {minimum: 6, maximum: 20}, 
                        uniqueness: true
  has_secure_password
  validates :password,  presence: true, length: {minimum: 8}
  # Regex for checking password format (1+ lowercase, 1+ uppercase, 1+ special characters)
  VALID_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/x
  validates :password, :format => {with: VALID_PASSWORD_REGEX, message: "Password must contain at least 1 each of: lowercase letter, uppercase letter, symbol"}
  validates_length_of :passphrase_text, :minimum => 1, :too_short => "Your passphrase must be 4 words long.", :tokenizer => lambda {|str| str.scan(/\w+/) }
end

