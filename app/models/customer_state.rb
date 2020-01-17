class CustomerState < ActiveRecord::Base
  attr_accessible :name,:icon,:color,:status
  has_attached_file :icon, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :icon, :content_type => /\Aimage\/.*\Z/
  has_many :customers
  # after_create :send_notification
  
  def send_notification
  	Notification.send_fcm_notification("new customer state created")
  end
end
