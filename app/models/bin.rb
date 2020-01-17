class Bin < ActiveRecord::Base
  belongs_to :store_rack
  belongs_to :warehouse_rack
  has_one :bin_product, dependent: :destroy
  attr_accessible :breadth, :height, :name, :row_no, :unique_identify_no, :width,:bin_unique_id,:rack_unique_id, :status
end
