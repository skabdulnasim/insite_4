class OrderSlot < ActiveRecord::Base
  attr_accessible :delivery_date, :order_id, :slot_id

  # Model Relations
  belongs_to :order 
  belongs_to :slot

  # Model Validations
  # validates :order_id, :presence => true
  validates :slot_id, :presence => true
  after_create :add_slot_to_order
  # => Model Scopes
  scope :by_slot, lambda {|slot_id|where(["slot_id=?", slot_id])}
  scope :by_delivery_date, lambda {|delivery_date|where(["delivery_date=?", delivery_date])}
  scope :set_slot_in, lambda {|slot_ids|where(["slot_id IN(?)", slot_ids])}
  def add_slot_to_order
    if self.slot_id.present?
      order = Order.find(self.order_id)
      order.update_attributes(:slot_id=> self.slot_id) if order.present?
      order.order_details.each do |order_details|
        order_details.update_attributes(:slot_id=>self.slot_id) if order_details.present?
      end
    end
  end
end