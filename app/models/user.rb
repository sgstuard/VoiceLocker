class User < ActiveRecord::Base
	validates :username, 	presence: true, length: {minimum: 6, maximum: 20}, 
							uniqueness: true
	has_secure_password
	validates :password,	presence: true, length: {minimum: 6}
end
