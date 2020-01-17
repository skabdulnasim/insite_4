class BillOrder < ActiveRecord::Base
  attr_accessible :bill_id, :order_id

  belongs_to :bill
  belongs_to :order

  accepts_nested_attributes_for :order

  after_save :update_order_as_billed, :update_table_state, :update_resource_state

  validates :order, :presence => true
  validates :order_id, uniqueness: true

  ### => Model Delegations
  delegate  :billed, :unit_id, :order_total_without_tax,
            :to => :order,
            :prefix => true
  delegate :billed?, to: :order
  
  def self.save_bill_order(bill_id, order_id)
    _bill_order = BillOrder.new
    _bill_order[:bill_id] = bill_id
    _bill_order[:order_id] = order_id
    _bill_order.save
  end 

  private

  def update_order_as_billed
  	_order = Order.find(self.order_id)
  	_order.update_attribute(:billed, 1)
  end

  def update_table_state
    _order = self.order
    _bill = self.bill
    if _order.source == 'inhouse' && _order.deliverable_type == 'Table'
      Table.update_table_state(5,_bill.unit_id,_order.deliverable_id,_bill.user_id,_bill.device_id)
    end
  end

  def update_resource_state
    _order = self.order
    _bill = self.bill
    if _order.source == 'inhouse' && _order.deliverable_type == 'Resource'
      Resource.update_resource_state(5,_bill.unit_id,_bill.deliverable_id,_bill.user_id,_bill.device_id)
    end
  end
end
