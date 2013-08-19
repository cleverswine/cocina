require 'recipescarfer'

class Recipe < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  has_many :photos, :dependent => :destroy
  
  validates_presence_of :title
  validates_presence_of :tag_list
  validates_presence_of :time_to_make
  validates :servings, :numericality => { :only_integer => true }
  validates :rating, :numericality => { :only_integer => true }
  
  acts_as_taggable_on :tags
  
  attr_accessible :title, :description, :ingredients, :instructions, :source, :source_detail, :rating, :servings, :time_to_make, :tag_list, :category_id  
  
  def update_with_scarfer(url)
    url = 'http://' + url if !url.upcase.start_with?('HTTP')
    self.source_detail = url
    scarfer = Scarfer.get_with_regex(url)
    if !scarfer
        scarfer = Scarfer.new
        scarfer.title = "{ \"node_path\": \"css: head title\" }"
        scarfer.description = "{ \"node_path\": \"css: meta[@name='description']\", \"attribute\": \"content\" }"
        self.errors.add('Scarfer', " - No scarfer found that matches the given URL: " + url)
    end  
    begin
        recipe_scarfer = RecipeScarfer.new(url)
    rescue => e
        self.errors.add('Scarfer', "couldn't read from url: " + url + ", error: " + e.message)
        return nil
    end
    self.title = importSecion(recipe_scarfer, scarfer.title).lstrip.rstrip
    self.description = importSecion(recipe_scarfer, scarfer.description).lstrip.rstrip
    self.ingredients = importSecion(recipe_scarfer, scarfer.ingredients).lstrip.rstrip
    self.instructions = importSecion(recipe_scarfer, scarfer.instructions).lstrip.rstrip    
    self.servings = importSecion(recipe_scarfer, scarfer.servings).lstrip.rstrip if scarfer.servings != ''
    self.time_to_make = importSecion(recipe_scarfer, scarfer.time_to_make).lstrip.rstrip if scarfer.time_to_make != ''
    self.source = scarfer.source_name  
    photo_url = importSecion(recipe_scarfer, scarfer.photo).lstrip.rstrip if scarfer.photo != ''
    return photo_url
  end
  
  def add_photo_from_url(url)
    return nil if (!url || url == '')
    return 'unable save photo from invalid url: ' + url if !url.upcase.start_with?('HTTP')
    begin
        photo = Photo.new
        photo.source = url
        photo.remote_photo_url = url
        photo.picture_from_url(url)
        return 'unable save photo from: ' + url if !photo.save        
        self.photos << photo
    rescue => e
        return 'unable to get photo from: ' + url + ' because: ' + e.message 
    end
    return nil
  end
  
  def self.search(filter)
    sql = "title LIKE :search_term OR description LIKE :search_term OR instructions LIKE :search_term OR ingredients LIKE :search_term"
    wild_term = '%' + filter[:term] + '%'

    query = (filter[:sort] == 'best' && !filter[:term].empty?) \
        ? Recipe.order("(title LIKE '#{wild_term}') desc, (ingredients LIKE '#{wild_term}') desc") \
        : Recipe.order(sort_clause(filter[:sort]))   
    query = query.where(sql, :search_term => wild_term) unless filter[:term] == ''
    query = query.scoped_by_category_id(filter[:category_id]) unless filter[:category_id].empty?
    query = query.tagged_with(filter[:tag]) unless filter[:tag].empty?
    
    return query.page(filter[:page]).per(filter[:per_page]) 
  end

  def self.search_title(filter)
    sql = "title LIKE :search_term"
    wild_term = '%' + filter[:term] + '%'
    
    query = Recipe.where(sql, :search_term => wild_term).order(sort_clause('alpha'))
    query = query.scoped_by_category_id(filter[:category_id]) unless filter[:category_id].empty?
    query = query.tagged_with(filter[:tag]) unless filter[:tag].empty?
    
    return query
  end
  
  private
  def self.sort_clause(sortkey)
    sort = case sortkey
       when 'date' then 'created_at desc'
       when 'alpha' then 'title asc'
       when 'alphadesc' then 'title desc'
       when 'rating' then 'rating desc'
       when 'best' then 'title asc'
       else 'created_at desc'
    end    
  end
  
  def importSecion(scarfer, json)
    begin    
        return '' if json.blank?
        settings = Scarfer.from_json(json)
        return scarfer.getSection(settings)
    rescue => e
        return e.message
    end
  end  
end
