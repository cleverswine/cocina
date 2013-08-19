# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

category = Category.find_by_name('Main Dishes')
if !category
	category = Category.new(:name => 'Main Dishes', :description => '', :sort_index => 0)
	category.save!
end

user = User.first
if !user
	user = User.new(:name => 'kevboo', :password => 'marcello', :password_confirmation => 'marcello')
    user.save!
end

pref = Preferences.first
if !pref
    pref = Preferences.new(:user_id => user.id, :per_page => 15, :import_action => 'new', :default_tag_list => 'Imported', :default_category_id => category.id)
    pref.save!
end

recipe = Recipe.find_by_title('This is a test recipe')
if !recipe
	recipe = Recipe.new(:title => 'This is a test recipe', :tag_list => 'Chicken', :description => 'test', :ingredients => 'test', :instructions => 'test', :rating => 3, :servings => 2, :time_to_make => "30", :category_id => 1)
	recipe.user = user
	recipe.save!
    #p = Photo.new
    #p.remote_photo_url = 'http://farm8.staticflickr.com/7065/6953655308_eea793ef98_b_d.jpg'
    #p.save!
    #recipe.photos << p
end