class DeliveryBoy < ActiveRecord::Base
  attr_accessible :address, :email, :name, :phone_no,:password,:password_confirmation
  has_many :orders
  has_many :return_items
  has_many :delivery_boys_units
  has_many :units, through: :delivery_boys_units
  has_many :settlements, as: :client

  validates :name,  presence: true, length: { maximum: 50 } 
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :phone_no,  presence: true, :numericality => true,
            :length => { :minimum => 10, :maximum => 15 }   
  has_secure_password
  validates :password, length: { minimum: 6 }, :if => lambda{|u| u.password.present?} 

  # Model Scopes
  scope :search_by_name, lambda {|name|where(["lower(name) like ?", "%#{name.downcase}%"])}

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end              
end
