class UnitImage < ActiveRecord::Base
  attr_accessible :image, :unit_id

  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  belongs_to	:unit
end