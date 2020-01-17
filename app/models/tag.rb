class Tag < ActiveRecord::Base
  attr_accessible :color, :icon, :name, :status, :tag_type, :tag_group_id
  has_attached_file :icon, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :icon, :content_type => /\Aimage\/.*\Z/
  has_many :customers,through: :customer_tag 
  has_and_belongs_to_many :menu_products
  belongs_to :tag_group
  #Model scope 
  scope :active, lambda { where(["status = ?",'active']) }
end
