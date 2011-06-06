class AddTokenAndSecretToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :token, :string, :length => 512
    add_column :accounts, :secret, :string, :length => 512
  end

  def self.down
    remove_column :accounts, :token
    remove_column :accounts, :secret
  end
end
