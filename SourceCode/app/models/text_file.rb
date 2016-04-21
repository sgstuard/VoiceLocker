# File and first and last lines created by Rails. All other code ours.
# Contributors: Simon Stuard

class TextFile < ActiveRecord::Base
  validates :title, presence: true,
                    length: {minimum: 1}
end
