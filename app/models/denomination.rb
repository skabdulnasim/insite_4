class Denomination < ActiveRecord::Base
  
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  attr_accessible :country_id, :name, :value, :image
  belongs_to :country
  belongs_to :cash_in
  belongs_to :cash_out
  has_many :cash_in_descriptions
  has_many :cash_out_descriptions
end
