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

ActiveRecord::Schema.define(:version => 20120623221348) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "sort_index"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "photos", :force => true do |t|
    t.datetime "photo_updated_at"
    t.string   "photo_content_type"
    t.string   "photo_file_name"
    t.integer  "photo_file_size"
    t.string   "remote_photo_url"
    t.string   "name"
    t.string   "source"
    t.boolean  "is_primary"
    t.integer  "recipe_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "per_page"
    t.string   "import_action"
    t.integer  "default_category_id"
    t.string   "default_tag_list"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "recipes", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "ingredients"
    t.text     "instructions"
    t.string   "source"
    t.string   "source_detail"
    t.integer  "rating"
    t.integer  "servings"
    t.string   "time_to_make"
    t.integer  "user_id"
    t.string   "tags_as_string"
    t.integer  "category_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "scarfers", :force => true do |t|
    t.string   "name"
    t.string   "url_match"
    t.string   "source_name"
    t.text     "title",        :limit => 255
    t.text     "description",  :limit => 255
    t.text     "ingredients",  :limit => 255
    t.text     "instructions", :limit => 255
    t.text     "photo",        :limit => 255
    t.text     "time_to_make", :limit => 255
    t.text     "servings",     :limit => 255
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "is_admin",        :default => false
    t.string   "password_digest"
    t.string   "auth_token"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

end