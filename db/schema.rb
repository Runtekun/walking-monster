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

ActiveRecord::Schema[7.2].define(version: 2026_06_03_165616) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "post_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "destinations", force: :cascade do |t|
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "start"
    t.string "end"
    t.string "distance"
    t.string "duration"
    t.integer "steps"
    t.bigint "user_id", null: false
    t.datetime "walked_at"
    t.index ["user_id"], name: "index_destinations_on_user_id"
  end

  create_table "monster_species", force: :cascade do |t|
    t.string "name_stage_1"
    t.string "name_stage_2"
    t.string "name_stage_3"
    t.text "description"
    t.integer "evolution_level_1"
    t.integer "evolution_level_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "rankings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "rank"
    t.integer "score"
    t.string "category"
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "recorded_at"], name: "index_rankings_on_category_and_recorded_at"
    t.index ["user_id"], name: "index_rankings_on_user_id"
  end

  create_table "user_monsters", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "monster_species_id", null: false
    t.integer "level", default: 1, null: false
    t.integer "experience", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["monster_species_id"], name: "index_user_monsters_on_monster_species_id"
    t.index ["user_id"], name: "index_user_monsters_on_user_id"
  end

  create_table "user_rankings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "score", null: false
    t.string "ranking_category", null: false
    t.string "ranking_period", null: false
    t.date "period_start"
    t.date "period_end"
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ranking_category", "ranking_period", "period_start"], name: "index_rankings_on_cat_and_period"
    t.index ["user_id"], name: "index_user_rankings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.string "provider"
    t.string "uid"
    t.integer "goal_steps"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "destinations", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "rankings", "users"
  add_foreign_key "user_monsters", "monster_species", column: "monster_species_id"
  add_foreign_key "user_monsters", "users"
  add_foreign_key "user_rankings", "users"
end
