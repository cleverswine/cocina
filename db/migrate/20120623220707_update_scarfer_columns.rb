class UpdateScarferColumns < ActiveRecord::Migration
  def change
    change_table :scarfers do |t|
        t.change :title, :text
        t.change :description, :text
        t.change :ingredients, :text
        t.change :instructions, :text
        t.change :photo, :text
        t.change :time_to_make, :text
        t.change :servings, :text
    end
  end
end
