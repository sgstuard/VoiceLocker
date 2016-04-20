# File and first and last lines created by Rails. All other code ours.
# Contributors: Alex Humphries

class TextFile < ActiveRecord::Base
  validates :title, presence: true,
                    length: {minimum: 1}
end
