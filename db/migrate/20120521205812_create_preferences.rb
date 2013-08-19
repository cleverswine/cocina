class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :user_id
      t.integer :per_page
      t.string :import_action
      t.integer :default_category_id
      t.string :default_tag_list
      t.timestamps
    end
  end
end
