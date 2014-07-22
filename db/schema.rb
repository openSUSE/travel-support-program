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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140718101718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: true do |t|
    t.integer  "auditable_id",                null: false
    t.string   "auditable_type",              null: false
    t.integer  "owner_id",                    null: false
    t.string   "owner_type",                  null: false
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "action",                      null: false
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.text     "comment"
    t.datetime "created_at",                  null: false
  end

  add_index "audits", ["auditable_id", "auditable_type", "version"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "bank_accounts", force: true do |t|
    t.string   "holder"
    t.string   "bank_name"
    t.string   "format"
    t.string   "iban"
    t.string   "bic"
    t.string   "national_bank_code"
    t.string   "national_account_code"
    t.string   "country_code"
    t.string   "bank_postal_address"
    t.integer  "reimbursement_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "budgets", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "amount"
    t.string   "currency"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "budgets", ["currency"], name: "index_budgets_on_currency", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "machine_id"
    t.string   "machine_type"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "private"
  end

  add_index "comments", ["private"], name: "index_comments_on_private", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "espinita_audits", force: true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.text     "audited_changes"
    t.string   "comment"
    t.integer  "version"
    t.string   "action"
    t.string   "remote_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "espinita_audits", ["auditable_id", "auditable_type"], name: "index_espinita_audits_on_auditable_id_and_auditable_type", using: :btree
  add_index "espinita_audits", ["user_id", "user_type"], name: "index_espinita_audits_on_user_id_and_user_type", using: :btree

  create_table "events", force: true do |t|
    t.string   "name",                            null: false
    t.text     "description"
    t.string   "country_code"
    t.string   "url"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "validated"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "visa_letters"
    t.datetime "request_creation_deadline"
    t.datetime "reimbursement_creation_deadline"
    t.integer  "budget_id"
    t.string   "shipment_type"
  end

  add_index "events", ["budget_id"], name: "index_events_on_budget_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "reimbursement_id"
    t.date     "date"
    t.decimal  "amount"
    t.string   "currency"
    t.decimal  "cost_amount"
    t.string   "cost_currency"
    t.string   "method"
    t.string   "code"
    t.string   "subject"
    t.text     "notes"
    t.string   "file"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "postal_addresses", force: true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "city"
    t.string   "postal_code"
    t.string   "county"
    t.string   "country_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursement_attachments", force: true do |t|
    t.integer  "reimbursement_id"
    t.string   "title",            null: false
    t.string   "file",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "reimbursement_links", force: true do |t|
    t.integer  "reimbursement_id"
    t.string   "title",            null: false
    t.string   "url",              null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "reimbursements", force: true do |t|
    t.string   "state"
    t.integer  "user_id",          null: false
    t.integer  "request_id",       null: false
    t.text     "description"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "state_updated_at"
    t.string   "acceptance_file"
  end

  create_table "request_expenses", force: true do |t|
    t.integer  "request_id",         null: false
    t.string   "subject"
    t.string   "description"
    t.decimal  "estimated_amount"
    t.string   "estimated_currency"
    t.decimal  "approved_amount"
    t.string   "approved_currency"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.decimal  "total_amount"
    t.decimal  "authorized_amount"
  end

  create_table "requests", force: true do |t|
    t.string   "state"
    t.integer  "user_id",              null: false
    t.integer  "event_id",             null: false
    t.text     "description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "state_updated_at"
    t.boolean  "visa_letter"
    t.integer  "postal_address_id"
    t.string   "contact_phone_number"
    t.string   "type"
  end

  add_index "requests", ["event_id"], name: "index_requests_on_event_id", using: :btree
  add_index "requests", ["postal_address_id"], name: "index_requests_on_postal_address_id", using: :btree
  add_index "requests", ["type"], name: "index_requests_on_type", using: :btree
  add_index "requests", ["user_id"], name: "index_requests_on_user_id", using: :btree

  create_table "state_changes", force: true do |t|
    t.integer  "machine_id",   null: false
    t.string   "machine_type", null: false
    t.string   "state_event"
    t.string   "from",         null: false
    t.string   "to",           null: false
    t.integer  "user_id"
    t.string   "notes"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "type"
  end

  add_index "state_changes", ["type"], name: "index_state_changes_on_type", using: :btree

  create_table "user_profiles", force: true do |t|
    t.integer  "user_id",               null: false
    t.integer  "role_id",               null: false
    t.string   "full_name"
    t.string   "phone_number"
    t.string   "country_code"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "second_phone_number"
    t.string   "description"
    t.string   "location"
    t.date     "birthday"
    t.string   "website"
    t.string   "blog"
    t.string   "passport"
    t.string   "alternate_id_document"
    t.string   "zip_code"
    t.string   "postal_address"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "nickname",                              null: false
    t.string   "locale",                 default: "en", null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
