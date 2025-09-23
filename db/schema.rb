# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_23_130545) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.integer "lead_limit"
    t.string "domain"
    t.string "crm_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "leads", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id", null: false
    t.string "email"
    t.string "phone"
    t.bigint "project_id", null: false
    t.bigint "status_id", null: false
    t.text "comment"
    t.bigint "user_id", null: false
    t.datetime "ncd"
    t.boolean "crm_created"
    t.string "crm_lead_no"
    t.text "crm_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "user_assinged_on"
    t.integer "churn_count"
    t.string "code"
    t.index ["company_id"], name: "index_leads_on_company_id"
    t.index ["project_id"], name: "index_leads_on_project_id"
    t.index ["status_id"], name: "index_leads_on_status_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "leads_call_logs", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "user_id", null: false
    t.bigint "status_id"
    t.datetime "ncd"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_leads_call_logs_on_lead_id"
    t.index ["status_id"], name: "index_leads_call_logs_on_status_id"
    t.index ["user_id"], name: "index_leads_call_logs_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "training_website_url"
    t.string "training_video"
    t.index ["company_id"], name: "index_projects_on_company_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_managers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_user_managers_on_manager_id"
    t.index ["user_id", "manager_id"], name: "index_user_managers_on_user_id_and_manager_id", unique: true
    t.index ["user_id"], name: "index_user_managers_on_user_id"
    t.check_constraint "user_id <> manager_id", name: "no_self_management"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "phone"
    t.bigint "role_id", null: false
    t.string "assignee_uuid"
    t.text "assignee_validated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "code"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "leads", "companies"
  add_foreign_key "leads", "projects"
  add_foreign_key "leads", "statuses"
  add_foreign_key "leads", "users"
  add_foreign_key "leads_call_logs", "leads"
  add_foreign_key "leads_call_logs", "statuses"
  add_foreign_key "leads_call_logs", "users"
  add_foreign_key "projects", "companies"
  add_foreign_key "user_managers", "users"
  add_foreign_key "user_managers", "users", column: "manager_id"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "roles"
end
