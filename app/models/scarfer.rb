class Scarfer < ActiveRecord::Base
  validates_presence_of :name, :source_name, :url_match

  def url_match_qualified
    url_match.upcase.start_with?('HTTP') \
        ? url_match \
        : 'http://' + url_match
  end
  
  def update_attributes_from_yaml(yaml_obj)
    self.name = yaml_obj.name
    self.url_match = yaml_obj.url_match
    self.source_name = yaml_obj.source_name
    self.title = yaml_obj.title
    self.description = yaml_obj.description
    self.ingredients = yaml_obj.ingredients
    self.instructions = yaml_obj.instructions
    self.photo = yaml_obj.photo
    self.time_to_make = yaml_obj.time_to_make
    self.servings = yaml_obj.servings
  end
  
  def self.get_with_regex(url)
    all.each do |scarfer|
      scarfer_url = scarfer.url_match
      p scarfer_url
      if url.match(scarfer_url)        
        return scarfer
      else
        p 'no match'
      end      
    end
    return nil
  end
  
  def self.from_json(json)
    ActiveSupport::JSON.decode(json.gsub("\n",''))
  end
  
end
