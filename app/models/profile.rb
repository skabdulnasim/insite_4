class Profile < ActiveRecord::Base
  attr_accessible :appurl, :contact_no, :firstname, :lastname, :full_name, :address, :city, :zip_code, :state, :country, :latitude, :longitude
  attr_reader :fullname
  
  belongs_to :user
  belongs_to :customer
  geocoded_by :address
  after_validation :geocode
  reverse_geocoded_by :latitude, :longitude, :address => :address

  scope :by_role_name, lambda { |role_name| joins(:users).merge(Users.by_role_name(role_name))}

  def full_name=(name)
    split = name.split(" ", 2)
    self.firstname = split.first
    self.lastname = split.last
  end

  def full_name
    [firstname, lastname].join(' ')
  end  

  def self.name_like(search)  
    if search  
      where("firstname || ' ' || lastname ILIKE ?", "%#{search}%")
    else  
      all  
    end  
  end
end
