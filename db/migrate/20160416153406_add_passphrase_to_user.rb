class AddPassphraseToUser < ActiveRecord::Migration
  def change
    add_column :users, :passphrase_text, :string
    add_column :users, :passphrase_recording, :string
  end
end
