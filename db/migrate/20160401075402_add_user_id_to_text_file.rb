class AddUserIdToTextFile < ActiveRecord::Migration
  def change
    add_column :text_files, :user_id, :integer
  end
end
