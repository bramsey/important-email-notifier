class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.string :value
      t.integer :user_id
      t.integer :message_id

      t.timestamps
    end
    add_index :tokens, :value
  end

  def self.down
    drop_table :tokens
  end
end
