class Category < ActiveRecord::Base
  has_many :recipes
  
  validates_uniqueness_of :name
  validates_presence_of :name
  
  before_destroy :validate_no_recipes  
  
  def recipe_tags
    recipes.tag_counts_on(:tags).order('name')
  end
  
  protected
  
  def validate_no_recipes
    if self.recipes.any?
      errors.add('the category', 'cannot be deleted because there are recipes filed under it.')
      return false
    end
  end
end
