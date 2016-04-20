# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'json'
User.create!(:id => 1, :username => 'testing',:password => "thisisatest", :password_digest => "$2a$10$i.LPKUOfFOxm0dqOeaEKMuamsaYxWSQ7vQjMIITFNR5hG7NuoomDm", :passphrase_text => "black xylophone cat crocodile", :passphrase_recording => "test_write_user_id_testing.raw", :passphrase_fingerprint => {"data":{"compressed":"AQAACom2KFKyEfeJv-iNZviMVzGa_MLFQ60rACSEMYYIgAg","raw":[575583819,860861003,856535755,857600731,857601003,857334251,861421803,871891099,838407323,817568985]}})
puts 'user created'