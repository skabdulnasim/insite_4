class Attendance < ActiveRecord::Base
  attr_accessible :latituted, :longituted, :image
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/xyz.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/  
end
