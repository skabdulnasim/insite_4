class StoreRequisitionMetum < ActiveRecord::Base
  belongs_to :store_requisition,:class_name => "StoreRequisition", :foreign_key => "requisition_id"
  belongs_to :product
  belongs_to :color
  belongs_to :size
  attr_accessible :product_ammount, :product_id, :product_unit_id, :requisition_id, :color_id, :size_id

  # => Model Validations
  validates :product_id, :presence => true
  validates :product_ammount, :presence => true
  validates :requisition_id, :presence => true

  #model scope
  scope :set_requistion,  lambda {|requistion_id|where(["requisition_id=?", requistion_id])}
  scope :set_product_in,  lambda {|product_ids|where(["product_id in (?)", product_ids])}
  scope :by_created_at,   lambda {|rq_date|where("date(created_at) =(?)" ,rq_date)}
  scope :by_requistions_in,  lambda {|requisition_ids|where(["requisition_id IN(?)", requisition_ids])}

  def self.get_product_details(data,rq_date)
    count = data.count.to_i
  	details = self.select("product_id,(product_ammount*#{count}) as total_amount").set_requistion(data.store_requisition_id).by_created_at(rq_date)     
  end
end
