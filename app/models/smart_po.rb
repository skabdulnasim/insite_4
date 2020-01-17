class SmartPo < ActiveRecord::Base
  attr_accessible :name, :source_unit, :user_id

  #Model Relations
  belongs_to :user
  belongs_to :unit, :foreign_key => :source_unit
  has_many :purchase_orders
  belongs_to :vendor
end
