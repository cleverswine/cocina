class ApplicationController < ActionController::Base
  protect_from_forgery  
  before_filter :authenticate_user
  
  private  
  
  def authenticate_user
    if current_user.nil?
      redirect_to login_url
    end
  end

  def current_user  
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]  
  end  
  
  def authenticate_is_admin
    if !current_user || !current_user.is_admin
        cookies.delete(:auth_token) 
        redirect_to login_url, :alert => "Go away"
    end
  end
    
  def get_categories  
    @categories = categories_from_cache
  end
    
  def categories_from_cache    
    Rails.cache.fetch("categories", :expires_in => 12.hours) do
      cat_array = Array.new
      Category.order('sort_index').each do |cat|
        tag_map = cat.recipes.tag_counts.order('name asc').map {|t| {:name => t.name, :count => t.count} }
        cat_array << { :id => cat.id, :name => cat.name, :tags => tag_map }
      end
      cat_array
    end
  end
  
  def invalidate_categories
    Rails.cache.delete("categories")
  end
    
  def get_recipe_count
    Rails.cache.fetch("recipe_count", :expires_in => 12.hours) do
        Recipe.count
    end
  end
  
  def invalidate_recipe_count
    Rails.cache.delete("recipe_count")
  end
  
  # allows it to be used from Views
  helper_method :current_user
  helper_method :get_recipe_count
end
