class CreateNotifoServices < ActiveRecord::Migration
  def self.up
    create_table :notifo_services do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :notifo_services
  end
end
