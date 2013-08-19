class Admin::UsersController < ApplicationController
  
  before_filter :authenticate_is_admin
  before_filter :authenticate_not_self_and_admin, :only => :destroy
  layout 'admin'
  
  def show
  end
  
  def index
    @users = User.order('created_at')
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.name = params[:user][:name]
    @user.description = params[:user][:description]
    @user.is_admin = params[:user][:is_admin]
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
        redirect_to admin_users_path, :notice => 'User was successfully updated.' 
    else
        render :action => "edit" 
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      redirect_to admin_users_path, :notice => 'User was successfully created.'
    else
      render :action => "new" 
    end    
  end

  def destroy
    @user = User.find(params[:id])
    
    if @user.destroy
      redirect_to admin_users_path, :notice => 'User was successfully removed.'
    else
      redirect_to admin_users_path, :notice => 'User was NOT successfully removed.'
    end 
  end
  
  private
  def authenticate_not_self_and_admin
    if params[:id] && params[:id] == current_user.id && current_user.is_amdin
        redirect_to admin_users_path, :notice => "You can't delete youself while Admin"
    end
  end
end