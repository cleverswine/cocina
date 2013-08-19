class CreateScarfers < ActiveRecord::Migration
  def change
    create_table :scarfers do |t|
    
      t.string :name
      t.string :url_match
      t.string :source_name
      
      t.string :title      
      t.string :description     
      t.string :ingredients
      t.string :instructions
      t.string :photo
      t.string :time_to_make
      t.string :servings

      t.timestamps
    end
  end
end
