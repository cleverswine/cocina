require 'recipescarfer'

class Admin::ScarfersController < ApplicationController

    before_filter :authenticate_is_admin, :except => [:index, :show]
    layout 'admin'
  
    def new
        @scarfer = Scarfer.new
    end
    
    def create
        @scarfer = Scarfer.new(params[:scarfer])
        
        if @scarfer.save
          redirect_to admin_scarfers_path, :notice => 'Scarfer was successfully created.'
        else
          render :action => "new" 
        end 
    end
    
    def edit
        @scarfer = Scarfer.find(params[:id])
    end
    
    def update
        @scarfer = Scarfer.find(params[:id])
    
        if @scarfer.update_attributes(params[:scarfer])
            redirect_to admin_scarfers_path, :notice => 'Scarfer was successfully updated.' 
        else
          render :action => "edit" 
        end
    end
    
    def destroy
        @scarfer = Scarfer.find(params[:id])
        if @scarfer.destroy
          redirect_to admin_scarfers_path, :notice => 'Scarfer was successfully removed.'
        else
          redirect_to admin_scarfers_path, :notice => 'Scarfer was NOT successfully removed.'
        end 
    end
    
    def export
        @scarfer = Scarfer.find(params[:id])
        send_data @scarfer.to_yaml, :filename => @scarfer.name.gsub(' ', '_') + '.yaml'
    end
    
    def import
        y = params[:yaml_file].read
        @scarfer = Scarfer.new
        @scarfer.update_attributes_from_yaml(YAML::load(y))
        render :action => "new"
    end
    
    def index
        @scarfers = Scarfer.all
    end
    
    def show
        @scarfer = Scarfer.find(params[:id])
    end
    
    def dotest
        json = params['jsonstr']
        url = params['url']
        
        settings = Scarfer.from_json(json)
        recipe_scarfer = RecipeScarfer.new(params['url'])
        
        result = 'no result'
        
        begin
            result = recipe_scarfer.getSection(settings)
        rescue => e
            result = e.message
        end
        render :text => result.lstrip.rstrip
    end    

end