class AddDeviseColumnsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      # if you already have a email column, you have to comment the below line and add 
      #the :encrypted_password column manually (see devise/schema.rb).
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.remove :salt
    end
    
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
  end

  def self.down
    # the columns below are manually extracted from devise/schema.rb.
    change_table :users do |t|
      t.remove :password_salt
      t.string "salt"
      t.remove :authentication_token
      t.remove :confirmation_token
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_token
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip
    end
    
    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token
  end
end
