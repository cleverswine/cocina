require "open-uri"

class Photo < ActiveRecord::Base
  belongs_to :recipe  
  attr_accessible :recipe_id, :name, :source, :is_primary, :photo, :remote_photo_url
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "64x64>" }   
   
  def picture_from_url(url)
    self.photo = open(url)
  end
end
