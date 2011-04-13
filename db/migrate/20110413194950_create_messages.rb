class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :urgency
      t.boolean :disagree
      t.string :content
      t.integer :relationship_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
