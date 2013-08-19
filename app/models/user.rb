class User < ActiveRecord::Base
  has_secure_password  
  validates_presence_of :password, :on => :create 
  validates_uniqueness_of :name  
  has_many :recipes
  has_one :preferences
  attr_accessible :name, :description, :is_admin, :password, :password_confirmation  
  
  # if we ever create a new user, they will need a token
  # for cookie storage (remember me)
  before_create { generate_token(:auth_token) } 
  
  def generate_token(column)  
    begin  
      self[column] = SecureRandom.base64.tr("+/", "-_")
    end while User.exists?(column => self[column])  
  end

  def change_password2(newpassword, confirm)
    self.password = newpassword
    self.password_confirmation = confirm
    self.save!
  end
  
  def change_password(newpassword)
    self.password = newpassword
    self.password_confirmation = newpassword
    self.save!
  end
end
