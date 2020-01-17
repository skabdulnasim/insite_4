class WarehouseMetum < ActiveRecord::Base
  attr_accessible :row_unique_id, :store_id
  belongs_to :store
  has_many :warehouse_racks, dependent: :destroy
  # after_create :provide_row_uid
  
  # def provide_row_uid
  # 	self.update_attribute(:row_unique_id,"R"+self.id.to_s)
  # end
end
