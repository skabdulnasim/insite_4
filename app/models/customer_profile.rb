class CustomerProfile < ActiveRecord::Base
  #attr_accessible :customer_id, :address, :age, :anniversary, :contact_no, :customer_name, :dob, :firstname, :gender, :lastname, :picture_url, :profile_url, :profile_picture, :customer_identification
  attr_accessible :customer_id, :address, :age, :anniversary, :contact_no, :customer_name, :dob, :firstname, :gender, :lastname, :picture_url, :profile_url, :profile_picture, :pan_no, :alternate_name, :alternate_mobile
  
  has_attached_file :profile_picture, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/
 

  # has_attached_file :customer_identification, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  # validates_attachment_content_type :customer_identification, :content_type => /\Aimage\/.*\Z/

 #  attr_reader :customer_name
  
  #scope :by_name, lambda{|data| where(["customer_name LIKE ? OR firstname LIKE ? OR lastname LIKE ?","%#{data}%","%#{data}%","%#{data}%"])}
  #  attr_reader :customer_name

	# belongs_to :customer
  
 #  def customer_name=(name)
 #    name = name.split(' ')
 #    self.firstname = name[0]
 #    self.lastname = name[1]
 #  end

 #  def customer_name
 #    firstname.present? ? "#{firstname} #{lastname}" : ""
 #  end
end