class Label < ActiveRecord::Base
  attr_accessible :name, :status, :customer_state, :icon
  has_attached_file :icon, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

  scope :by_customer_state, lambda{|customer_state|where("customer_state=?", customer_state)}
end
