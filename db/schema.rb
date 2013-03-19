# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130318221145) do

  create_table "events", :force => true do |t|
    t.string   "name",         :null => false
    t.text     "description"
    t.string   "country_code"
    t.string   "url"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "validated"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "reimbursements", :force => true do |t|
    t.string   "state"
    t.integer  "user_id",               :null => false
    t.integer  "request_id",            :null => false
    t.text     "description"
    t.text     "requester_notes"
    t.text     "tsp_notes"
    t.text     "administrative_notes"
    t.datetime "incomplete_since"
    t.datetime "tsp_pending_since"
    t.datetime "tsp_approved_since"
    t.datetime "payment_pending_since"
    t.datetime "payed_since"
    t.datetime "completed_since"
    t.datetime "canceled_since"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "request_expenses", :force => true do |t|
    t.integer  "request_id",         :null => false
    t.string   "subject"
    t.string   "description"
    t.decimal  "estimated_amount"
    t.string   "estimated_currency"
    t.decimal  "approved_amount"
    t.string   "approved_currency"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.decimal  "total_amount"
    t.decimal  "authorized_amount"
  end

  create_table "requests", :force => true do |t|
    t.string   "state"
    t.integer  "user_id",          :null => false
    t.integer  "event_id",         :null => false
    t.text     "description"
    t.text     "requester_notes"
    t.text     "tsp_notes"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "incomplete_since"
    t.datetime "submitted_since"
    t.datetime "approved_since"
    t.datetime "accepted_since"
    t.datetime "canceled_since"
  end

  add_index "requests", ["event_id"], :name => "index_requests_on_event_id"
  add_index "requests", ["user_id"], :name => "index_requests_on_user_id"

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "role_id",      :null => false
    t.string   "full_name"
    t.string   "phone_number"
    t.string   "country_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",   :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "nickname",                                 :null => false
    t.string   "locale",                 :default => "en", :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
