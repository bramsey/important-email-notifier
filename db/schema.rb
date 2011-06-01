# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110601164724) do

  create_table "accounts", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => false
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "urgency"
    t.boolean  "disagree"
    t.string   "content"
    t.integer  "relationship_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["relationship_id"], :name => "index_messages_on_relationship_id"

  create_table "relationships", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow"
  end

  add_index "relationships", ["recipient_id"], :name => "index_relationships_on_recipient_id"
  add_index "relationships", ["sender_id", "recipient_id"], :name => "index_relationships_on_sender_id_and_recipient_id", :unique => true
  add_index "relationships", ["sender_id"], :name => "index_relationships_on_sender_id"

  create_table "tokens", :force => true do |t|
    t.string   "value"
    t.integer  "user_id"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["value"], :name => "index_tokens_on_value", :unique => true

  create_table "users", :force => true do |t|
    t.string   "alias"
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "busy"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
