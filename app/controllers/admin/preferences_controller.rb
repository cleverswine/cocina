class Admin::PreferencesController < ApplicationController
    
    layout 'prefs'

    def edit
        @pref = Preferences.find_by_user_id(current_user.id)
    end
    
    def update
        @pref = Preferences.find_by_user_id(current_user.id)  
            
        if @pref.update_attributes(params[:preferences])
            session[:per_page] = nil
          
            if params['newpassword'] != ''
                if params['newpassword'] != params['newpasswordconfirm'] 
                    @pref.errors.add('Password', 'confirmation must match')
                else
                    current_user.change_password params[:newpassword]
                end
            end
        end
        
        if !@pref.errors.any?
            redirect_to edit_admin_preference_path(@pref), :notice => 'Your preferences were successfully updated.' 
        else
            render :action => "edit" 
        end        
    end
    
    def editaccount
        @user = current_user
    end
    
    def updateaccount
        @user = current_user        
        @user.name = params[:user][:name]
        @user.description = params[:user][:description]
        success = @user.save
        if success && params[:user][:password] != '' && params[:user][:password_confirmation] != ''
            if params[:user][:password] == params[:user][:password_confirmation]
                @user.change_password2 params[:user][:password], params[:user][:password_confirmation]
            else
                @user.errors.add('Password', "confirmation doesn't match")
                success = false
            end
        end
        if success
            redirect_to editaccount_admin_preferences_path, :notice => 'Your account was successfully updated.' 
        else
            render :action => "editaccount" 
        end        
    end
    
end