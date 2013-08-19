class Photo < ActiveRecord::Migration
  def change
    create_table :photos do |t|
        t.has_attached_file :photo
        t.string   "remote_photo_url"
		t.string   "name"
		t.string   "source"
		t.boolean  "is_primary"
		t.integer  "recipe_id"
		t.timestamps
    end
  end
end
