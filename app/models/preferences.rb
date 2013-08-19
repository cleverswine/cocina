class Preferences < ActiveRecord::Base    
    belongs_to :user
    
    attr_accessible :import_action, :per_page, :user_id, :default_tag_list, :default_category_id

    validates_presence_of :import_action, :default_tag_list, :default_category_id
    validates :per_page, :numericality => { :only_integer => true }
end
