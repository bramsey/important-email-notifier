class CreateEmailServices < ActiveRecord::Migration
  def self.up
    create_table :email_services do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :email_services
  end
end
