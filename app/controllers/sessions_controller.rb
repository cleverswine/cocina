class SessionsController < ApplicationController  

  skip_before_filter :authenticate_user, :only => [:new, :create]
    
  def new  
  end  
  
  def create  
    user = User.find_by_name(params[:name])  
    if user && user.authenticate(params[:password])  
      if params[:remember_me]  
        cookies.permanent[:auth_token] = user.auth_token  
      else  
        cookies[:auth_token] = user.auth_token    
      end  
      redirect_to root_url, :notice => "Logged in!"  
    else  
      flash.now.alert = "Invalid user name or password"  
      render "new"  
    end  
  end  
  
  def destroy  
    cookies.delete(:auth_token) 
    session[:filters] = nil
    redirect_to root_url, :notice => "Logged out!"  
  end 
end  