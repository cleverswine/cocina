class Admin::CategoriesController < ApplicationController
  
  before_filter :authenticate_is_admin
  layout 'admin'
  
  def show
  end
  
  def index
    @categories = Category.order('sort_index')
  end

  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])

    if @category.update_attributes(params[:category])
	  session['categories'] = nil
      redirect_to admin_categories_path, :notice => 'Category was successfully updated.' 
    else
      render :action => "edit" 
    end
  end

  def new
    @category = Category.new
  end

  def create
    max = Category.maximum('sort_index')
    @category = Category.new(params[:category])
    @category.sort_index = max + 1
    
    if @category.save
      session['categories'] = nil
      redirect_to admin_categories_path, :notice => 'Category was successfully created.'
    else
      render :action => "new" 
    end    
  end

  def destroy
    @category = Category.find(params[:id])
    if(params['killemall'])
      Recipe.destroy_all("category_id = #{@category.id}")
    end
    if(params['moveemall'])
      cat_id = params['newcategory']
      @category.recipes.each do |recipe|
        recipe.category_id = cat_id
        recipe.save
      end
      @category = Category.find(params[:id])
    end
    if @category.destroy
      session['categories'] = nil
      redirect_to admin_categories_path, :notice => 'Category was successfully removed.'
    else
      @categories = Category.where("id <> #{@category.id}").order('sort_index')
    end 
  end
  
  def reorder
    cats = Category.all
    cats.each do |cat|
      cat.sort_index = params['category'].index(cat.id.to_s) + 1
      cat.save
    end
    session['categories'] = nil
    render :nothing => true
  end
  
  def tagmaint
  end
  
  def tagname
    oldtag = params['tagname']
    newtag = params['newtag']
    notice = 'nothing was done'
    if !oldtag || !newtag || oldtag.blank? || newtag.blank?
        notice = 'You must specify a tag name and a new tag name'
    else
        newtagobj = Tag.find_by_name(newtag)
        if newtagobj
            # new tag already exists, so remove old one and add new one to recipes
            recipes = Recipe.tagged_with(oldtag)
            recipe_count = recipes.count.to_s
            recipes.each do |recipe|
                recipe.tag_list.remove(oldtag)
                recipe.tag_list << newtag if !recipe.tag_list.include?(newtag)
                recipe.save!
            end
            notice = recipe_count + ' recipes were updated from ' + oldtag + ' to ' + newtag
        else
            oldtagobj = Tag.find_by_name(oldtag)
            if oldtagobj
                oldtagobj.name = newtag
                oldtagobj.save!
                session['categories'] = nil
                notice = 'The tag ' + oldtag + ' was successfully changed to ' + newtag
            else
                notice = 'The specified tag name could not be found.'
            end        
        end
    end
    session['categories'] = nil
    redirect_to tagmaint_admin_categories_path, :notice => notice 
  end
end
