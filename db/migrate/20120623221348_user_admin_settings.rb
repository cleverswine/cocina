class UserAdminSettings < ActiveRecord::Migration
  def change
    user = User.find_by_name('kevboo')
    user = User.new(:name => 'kevboo', :password => 'marcello', :password_confirmation => 'marcello') unless user
    user.is_admin = true
    user.save!
    
    notadmin = User.new(:name => 'notadmin', :password => 'marcello', :password_confirmation => 'marcello')
    notadmin.is_admin = false
    notadmin.save!
    
    category = Category.first
    pref = Preferences.new(:user_id => notadmin.id, :per_page => 15, :import_action => 'new', :default_tag_list => 'Imported', :default_category_id => category.id)
    pref.save!    
  end
end
