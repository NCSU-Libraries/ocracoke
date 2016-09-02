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

ActiveRecord::Schema.define(version: 20160902010222) do

  create_table "images", force: :cascade do |t|
    t.string   "identifier"
    t.datetime "txt"
    t.datetime "hocr"
    t.datetime "json"
    t.integer  "resource_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["identifier"], name: "index_images_on_identifier", unique: true
    t.index ["resource_id"], name: "index_images_on_resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string   "identifier"
    t.datetime "txt"
    t.datetime "pdf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_resources_on_identifier", unique: true
  end

end
