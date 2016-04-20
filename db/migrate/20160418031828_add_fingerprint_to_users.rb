class AddFingerprintToUsers < ActiveRecord::Migration
  def change
    add_column :users, :passphrase_fingerprint, :string
  end
end
