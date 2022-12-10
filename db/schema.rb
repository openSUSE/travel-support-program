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

ActiveRecord::Schema.define(version: 20221210104059) do

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.text "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "username"
    t.string "request_uuid"
    t.integer "association_id"
    t.string "association_type"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "holder"
    t.string "bank_name"
    t.string "format"
    t.string "iban"
    t.string "bic"
    t.string "national_bank_code"
    t.string "national_account_code"
    t.string "country_code"
    t.string "bank_postal_address"
    t.integer "reimbursement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["currency"], name: "index_budgets_on_currency"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "machine_id"
    t.string "machine_type"
    t.text "body"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "private"
    t.index ["private"], name: "index_comments_on_private"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "espinita_audits", force: :cascade do |t|
    t.string "auditable_type"
    t.integer "auditable_id"
    t.string "user_type"
    t.integer "user_id"
    t.text "audited_changes"
    t.string "comment"
    t.integer "version"
    t.string "action"
    t.string "remote_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["auditable_type", "auditable_id"], name: "index_espinita_audits_on_auditable_type_and_auditable_id"
    t.index ["user_type", "user_id"], name: "index_espinita_audits_on_user_type_and_user_id"
  end

  create_table "event_emails", force: :cascade do |t|
    t.text "to"
    t.string "subject"
    t.text "body"
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_organizers", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "country_code"
    t.string "url"
    t.date "start_date"
    t.date "end_date"
    t.boolean "validated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "visa_letters"
    t.datetime "request_creation_deadline"
    t.datetime "reimbursement_creation_deadline"
    t.integer "budget_id"
    t.string "shipment_type"
    t.index ["budget_id"], name: "index_events_on_budget_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "reimbursement_id"
    t.date "date"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency"
    t.decimal "cost_amount", precision: 10, scale: 2
    t.string "cost_currency"
    t.string "method"
    t.string "code"
    t.string "subject"
    t.text "notes"
    t.string "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "postal_addresses", force: :cascade do |t|
    t.string "line1"
    t.string "line2"
    t.string "city"
    t.string "postal_code"
    t.string "county"
    t.string "country_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
  end

  create_table "reimbursement_attachments", force: :cascade do |t|
    t.integer "reimbursement_id"
    t.string "title", null: false
    t.string "file", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursement_links", force: :cascade do |t|
    t.integer "reimbursement_id"
    t.string "title", null: false
    t.string "url", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursements", force: :cascade do |t|
    t.string "state"
    t.integer "user_id", null: false
    t.integer "request_id", null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "state_updated_at"
    t.string "acceptance_file"
  end

  create_table "request_expenses", force: :cascade do |t|
    t.integer "request_id", null: false
    t.string "subject"
    t.string "description"
    t.decimal "estimated_amount", precision: 10, scale: 2
    t.string "estimated_currency"
    t.decimal "approved_amount", precision: 10, scale: 2
    t.string "approved_currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "total_amount", precision: 10, scale: 2
    t.decimal "authorized_amount", precision: 10, scale: 2
  end

  create_table "requests", force: :cascade do |t|
    t.string "state"
    t.integer "user_id", null: false
    t.integer "event_id", null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "state_updated_at"
    t.boolean "visa_letter"
    t.integer "postal_address_id"
    t.string "contact_phone_number"
    t.string "type"
    t.index ["event_id"], name: "index_requests_on_event_id"
    t.index ["postal_address_id"], name: "index_requests_on_postal_address_id"
    t.index ["type"], name: "index_requests_on_type"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "state_changes", force: :cascade do |t|
    t.integer "machine_id", null: false
    t.string "machine_type", null: false
    t.string "state_event"
    t.string "from", null: false
    t.string "to", null: false
    t.integer "user_id"
    t.string "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.index ["type"], name: "index_state_changes_on_type"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.string "full_name"
    t.string "phone_number"
    t.string "country_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "second_phone_number"
    t.string "description"
    t.string "location"
    t.date "birthday"
    t.string "website"
    t.string "blog"
    t.string "passport"
    t.string "alternate_id_document"
    t.string "zip_code"
    t.string "postal_address"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "nickname", null: false
    t.string "locale", default: "en", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
