class WarehouseRack < ActiveRecord::Base
  attr_accessible :rack_unique_id, :row_unique_id
  belongs_to :warehouse_metum
  has_many :bins, ->{order(id: :ASC)}, dependent: :destroy
  after_create :provide_rack_unique_id
  scope :rack_by_warehouse_metum_id, lambda{|warehouse_metum_id|where(["wirehouse_metum_id=?",warehouse_metum_id])}
  
  def provide_rack_unique_id
  end
end
