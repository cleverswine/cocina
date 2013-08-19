class Recipe < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
		t.string   "title"
		t.text     "description"
		t.text     "ingredients"
		t.text     "instructions"
		t.string   "source"
		t.string   "source_detail"
		t.integer  "rating"
		t.integer  "servings"
		t.string  "time_to_make"
		t.integer  "user_id"
		t.string   "tags_as_string"
		t.integer  "category_id"
		t.timestamps
    end
  end
end
