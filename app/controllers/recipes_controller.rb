class RecipesController < ApplicationController

  before_filter :get_categories, :only => [:index, :by_category, :by_category_and_tag, :cats, :new, :edit, :create, :update]
  before_filter :get_filters, :except => [:tags, :rate]
  before_filter :get_title, :only => [:index, :by_category, :by_category_and_tag]
  after_filter :invalidate_categories, :only => [:update, :create, :destroy]
  after_filter :invalidate_recipe_count, :only => [:create, :destroy]
  
  # tag auto-complete
  def tags
    render :json => Recipe.tag_counts_on(:tags).where("tags.name LIKE ?", "%#{params[:term]}%").limit(8).order('count desc').map(&:name) 
  end
  
  def cats
    render :partial => 'layouts/left_nav_cats'
  end
  
  # recipe index (all recipes)
  def indx
    @recipes = params['s'] == 's' ? Recipe.order('source asc') : Recipe.order('title asc')
    #render :layout => "two_column"    
  end
  
  # /recipes
  def index    
    keyword = @filters[:term].strip
    @recipes = Recipe.search(@filters)
    if keyword != '' && @recipes.count == 1
        clear_search_term
        redirect_to @recipes.first       
    else
        render :layout => "two_column"
    end    
  end
    
  # index by category
  def by_category
    category = Category.find(@filters[:category_id])    
    keyword = @filters[:term].strip
    @recipes = Recipe.search(@filters)
    if keyword != '' && @recipes.count == 1
        clear_search_term
        redirect_to @recipes.first       
    else
        render 'index', :layout => "two_column"
    end
  end
  
  # index by category and tag
  def by_category_and_tag
    category = Category.find(@filters[:category_id])    
    keyword = @filters[:term].strip
    @recipes = Recipe.search(@filters)
    if keyword != '' && @recipes.count == 1
        clear_search_term
        redirect_to @recipes.first       
    else
        render 'index', :layout => "two_column"
    end
  end
 
  # search autocomplete (index filter)
  def search_title      
    @recipes = Recipe.search_title(@filters)
    render :json => @recipes.map(&:title)  
  end
 
  # ajax call for star rating
  def rate
    recipe = Recipe.find(params[:id])
    recipe.rating = params['rating']
    recipe.save
    
    respond_to do |format|
      format.html { render :json => recipe.rating }
      format.json { render :json => recipe.rating }
    end
  end
  
  def move
    recipe = Recipe.find(params[:id])
    cat_id = params['cat_id']
    tag = params['tag']
    recipe.category_id = cat_id unless recipe.category_id == cat_id
    recipe.tag_list = tag if tag
    recipe.save
    invalidate_categories
    render :partial => 'recipe', :locals => { :recipe => recipe }
  end
  
  # delete
  def destroy
    recipe = Recipe.find(params[:id])
    recipe.destroy
    
    respond_to do |format|
      format.html { redirect_to recipes_url }
      format.json { head :no_content }
    end
  end
  
  # recipes/1
  def show
    @recipe = Recipe.find(params[:id])
    @title = @recipe.title
  end

  # print view
  def print
    @recipe = Recipe.find(params[:id])
    @title = @recipe.title
    render :layout => "print"
  end
  
  # recipes/new
  def new
    @title = 'New Recipe'
    @recipe = Recipe.new
    @recipe.rating = 3
    @recipe.servings = 4
    @recipe.time_to_make = 30
    @recipe.user = current_user
    
    prefs = Preferences.find_by_user_id(current_user.id)
    cat = Category.find(prefs.default_category_id)
    @recipe.category = cat ? cat : Category.find('sort_index').first
    @recipe.tag_list = prefs.default_tag_list
    
    if params['url']      
        @photo_url = @recipe.update_with_scarfer(params['url'])    
        if prefs.import_action == 'show'            
            if @recipe.save
                redirect_to @recipe, :notice => @recipe.add_photo_from_url(@photo_url)
            end
        end
    end    
  end
  
  # /recipes/1/edit
  def edit
    @recipe = Recipe.find(params[:id])
    @title = 'Edit :: ' + @recipe.title
  end
  
  # create recipe
  def create
    @recipe = Recipe.new(params[:recipe])
    @recipe.tag_list << params['new_tag_text'].to_s.strip if params['new_tag_checkbox'] && params['new_tag_text'].to_s.strip != ''
    @photo_url = params['photo_url']
    @recipe.user = current_user    
    n = 'The recipe was successfully created.'
    
    if @recipe.save
        photo_msg = @recipe.add_photo_from_url(@photo_url)
        n += photo_msg if photo_msg
        redirect_to @recipe, :notice => n
    else
        render :action => "new"
    end
  end
  
  # update recipe
  def update
    @recipe = Recipe.find(params[:id])
    
    if @recipe.update_attributes(params[:recipe])
      if params['new_tag_checkbox'] && params['new_tag_text'].to_s.strip != ''
        @recipe.tag_list << params['new_tag_text'].to_s.strip
        @recipe.save
      end
      redirect_to @recipe, :notice => 'The recipe was successfully updated.' 
    else
      render :action => "edit" 
    end
  end
 
  private
    
  def get_val(key, default_val)
    return params[key] if params[key]
    return session[:filters][key] if session[:filters] && session[:filters][key]
    return default_val
  end
  
  def set_val(key, val)
    @filters = default_filter unless @filters
    @filters[key] = val    
  end
  
  def get_title
    cat_name = @filters[:category_id].empty? ? '' : Category.find(@filters[:category_id]).name
    @title = 'All Recipes' if @filters[:category_id].empty? && @filters[:tag].empty?
    @title = "#{cat_name}" if !@filters[:category_id].empty? && @filters[:tag].empty?
    @title = "#{cat_name} :: #{@filters[:tag].capitalize}" if !@filters[:category_id].empty? && !@filters[:tag].empty?    
    @title += " :: filtered by '#{@filters[:term]}'" if !@filters[:term].empty?
  end
  
  def get_filters     
    # reset session filter if we've navigated to a different categoy or tag or done a global search
    session[:filters] = nil if params['all'] || params['category_id'] || params['tag'] || params['url'] || params['globalterm']
    
    # get/set values
    term = get_val(:term, '')
    set_val(:term, get_val(:globalterm, term))
    set_val(:page, params[:page] ||= '1')
    set_val(:per_page, get_val(:per_page, current_user.preferences.per_page))
    set_val(:category_id, get_val(:category_id, ''))
    set_val(:tag, get_val(:tag, ''))
    set_val(:sort, get_val(:sort, 'date'))
    set_val(:sort, 'best') unless @filters[:term].empty?
    
    # save to session
    session[:filters] = @filters
  end
  
  def default_filter
    return { 
       :category_id => '',
       :tag => '',
       :term => '',
       :sort => 'date',
       :page => '1',
       :per_page => current_user.preferences.per_page
      }
  end
  
  def clear_search_term
    # if there was an exact match, we need to clear the search term to avoid infinte loop to recipe details
    session[:filters][:term] = '' if session[:filters]        
  end   
end