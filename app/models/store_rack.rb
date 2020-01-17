class StoreRack < ActiveRecord::Base
  belongs_to :store
  belongs_to :warehouse_metum
  has_many :bins
  attr_accessible :height, :name, :width
end
