class LogItem < ActiveRecord::Base
  attr_accessible :from_store_id, :log_id, :product_id, :product_ammount, :store_id, :store_requisition_id, :status, :color_id, :size_id
  belongs_to :product
  belongs_to :store, foreign_key: "from_store_id"
  #model scope
  scope :set_product_in,  		lambda {|product_ids|where(["product_id in (?)", product_ids])}
  scope :na_requisitions, 		lambda { where(:status => '1') }
  scope :store_requistion,      lambda {|store_id|where(["store_id=?", store_id])}
  scope :by_created_at,   		lambda {|rq_date|where("date(created_at) =(?)" ,rq_date)}
end
