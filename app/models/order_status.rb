class OrderStatus < ActiveRecord::Base
  attr_accessible :description, :name, :color_code

  # scope :approved,    lambda {where("name =?", "approved")}
  def self.get_status(name)
    self.where("lower(name) =?", name.downcase)[0]
  end
end
