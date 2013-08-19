class PhotosController < ApplicationController
  
    def index
        @recipe = Recipe.find(params[:recipe_id])
        @photo = Photo.new
        @photo.recipe_id = @recipe.id
        @photos = @recipe.photos.order("is_primary desc")
    end
    
    def create
        @recipe = Recipe.find(params['recipe_id'])
        
        p = Photo.create(params[:photo])
        if p.remote_photo_url.blank?
            p.source = 'file'
        else
            p.picture_from_url(p.remote_photo_url)
            p.source = p.remote_photo_url
        end
        p.save!
        
        @recipe.photos << p
        
        redirect_to recipe_photos_path(@recipe), :notice => "The photo was successfully added"
    end
    
    def destroy
        @recipe = Recipe.find(params['recipe_id'])
        photo = Photo.find(params[:id])
        photo.destroy      

        redirect_to recipe_photos_path(@recipe), :notice => "The photo was successfully removed"     
    end
    
    def setprimary
        @recipe = Recipe.find(params['recipe_id'])
        photo_id = params[:id]
        @recipe.photos.each do |photo|
            photo.is_primary = photo.id.to_s == photo_id
            photo.save!
        end
        
        redirect_to recipe_photos_path(@recipe), :notice => "The primary photo was successfully set" 
    end
end
