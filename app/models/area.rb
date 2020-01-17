class Area < ActiveRecord::Base
  attr_accessible :descriptions, :name, :status, :user_id

  scope :by_unit_id, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_unit_list, lambda{|unit_arr|where(["unit_id IN(?)",unit_arr])}
  belongs_to :user
  has_many :zones
end
