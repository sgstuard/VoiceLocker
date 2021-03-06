class ChangeFingerprintDataTypeToVarchar < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :passphrase_fingerprint, :varchar
    end
  end
  def self.down
    change_table :users do |t|
      t.change :passphrase_fingerprint, :binary
    end
  end
end
