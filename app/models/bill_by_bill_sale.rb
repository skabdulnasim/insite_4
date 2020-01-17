class BillByBillSale < ActiveRecord::Base
  attr_accessible :advance_payment, :bill_amount, :bill_destination_id, :bill_discount_percentage, :bill_discounts, :bill_id, :bill_taxes, :biller, :biller_id, :biller_type, :boh_amount, :customer, :customer_id, :deliverable_id, :deliverable_to, :deliverable_type, :delivery_charges, :device_id, :discount, :grand_total, :is_service_charge, :lite_device_id, :order_details, :order_detail_combinations, :orders, :pax, :payments, :prefix, :proforma_id, :recorded_at, :remarks, :reservation_id, :resource_type, :roundoff, :section_id, :serial_no, :status, :suffix, :tax_amount, :unit_id, :user_id, :section, :unit, :deliverable
  belongs_to :bill
  after_create :calculate_dependence_data

  # => Model scopes
  scope :valid_bill,          lambda { where("status NOT IN ('no_charge','void','cancled')")}
  scope :unit_bills,          lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_recorded_at,      lambda {|from_date,upto_date|where('recorded_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :set_deliverable_type,lambda {|deliverable_type|where(["deliverable_type=?", deliverable_type.capitalize])}
  scope :section_bill,        lambda {|deliverable_id|where(["deliverable_id=? and deliverable_type = ?", deliverable_id,'Section'])}
  scope :by_section,          lambda {|section_id| where(["section_id=?", section_id])}
  # scope :by_paymentmode_type, lambda {|paymentmode| joins(:payments).where(payments: { paymentmode_type: paymentmode })}
  scope :only_discount_bills, lambda { where("discount > 0")}
  scope :check_bill_status,   lambda {|status| where("status IN (?)",status)}
  scope :set_unit_ids_in,   lambda {|unit_ids| where("unit_id IN (?)",unit_ids)}


  def update_json_data
    bill = self.bill
    _orders,_order_details,_order_detail_combinations,_tax_details,_bill_discounts,_unit,_section,_biller, _customer = Array.new, Array.new, Array.new, Array.new, Array.new, Array.new, Array.new, Array.new,Array.new
    bill.orders.each do |order|
      _orders.push(order.as_json)
      order.order_details.each do |od|
        od_json = od.as_json
        od_json[:p_basic_unit] = od.product.basic_unit
        od_json[:p_category] = od.menu_product.menu_category.name if od.menu_product.present?
        _order_details.push(od_json)
        od.order_detail_combinations.each do |odc|
          odc_json = odc.as_json
          odc_json[:order_id] = odc.order_detail.order_id
          odc_json[:p_basic_unit] = odc.product.basic_unit
          odc_json[:p_category] = 'addon'
          _order_detail_combinations.push(odc_json)
        end
      end  
    end
    bill.bill_tax_amounts.each do |b_tax|
      b_tax_json = b_tax.as_json
      b_tax_json[:tax_class_name] = b_tax.tax_class.name
      _tax_details.push(b_tax_json)
    end  
    bill.bill_discounts.each do |bill_discount|
      _bill_discounts.push(bill_discount.as_json)
    end  
    if bill.customer_id.present?
      if bill.customer.present?
        _arr = {}
        _arr[:customer] = bill.customer.as_json
        _arr[:profile] = bill.customer.profile.as_json
        _customer.push(_arr)
      end  
    end  
    #For json data
    _bill_discounts = JSON.generate(_bill_discounts)
    _tax_details = JSON.generate(_tax_details)
    _orders = JSON.generate(_orders)
    _order_details = JSON.generate(_order_details)
    _order_detail_combinations = JSON.generate(_order_detail_combinations)
    _unit = JSON.generate(_unit.push(bill.unit.as_json))
    # _biller = JSON.generate(_biller.push(bill.biller.as_json))
    if bill.biller.present?
      _arr = {}
      _arr[:biller] = bill.biller.as_json
      _arr[:profile] = bill.biller.profile.as_json
      _biller.push(_arr)
    end
    _biller = JSON.generate(_biller)
    _customer = JSON.generate(_customer)
    _section = JSON.generate(_section.push(bill.section.as_json))
    #for non json data
    bill_amount = bill.bill_amount
    bill_discount_percentage = bill.bill_discount_percentage
    advance_payment = bill.advance_payment
    boh_amount = bill.boh_amount
    delivery_charges = bill.delivery_charges
    discount = bill.discount
    grand_total = bill.grand_total
    is_service_charge = bill.is_service_charge
    tax_amount = bill.tax_amount
    customer_id = bill.customer_id
    status = bill.status
    self.update_attributes(:status => status, :delivery_charges => delivery_charges, :tax_amount => tax_amount, :customer_id => customer_id, :discount => discount, :grand_total => grand_total, :is_service_charge => is_service_charge, :bill_amount => bill_amount, :bill_discount_percentage => bill_discount_percentage, :advance_payment => advance_payment, :boh_amount => boh_amount, :orders => _orders, :order_details => _order_details, :order_detail_combinations => _order_detail_combinations, :bill_taxes => _tax_details, :unit => _unit, :section => _section, :bill_discounts => _bill_discounts,:biller => _biller, :customer => _customer)
  end

  def update_payment_data
    _payments = Array.new
    if self.bill.settlement.present?
      self.bill.settlement.payments.each do |payment|
        payment_json = payment.paymentmode.as_json
        payment_json[:p_mode_name] = payment.paymentmode_type
        _payments.push(payment_json)
      end  
    end  
    _payments = JSON.generate(_payments)
    self.update_attributes(:status => bill.status, :payments => _payments)
  end

  def calculate_dependence_data
    _delivarable = Array.new
    _arr = {}
    if self.bill.deliverable.present?
      if self.deliverable_type == "Customer"
        _arr[:customer] = self.bill.deliverable.as_json
        _arr[:profile] = self.bill.deliverable.profile.as_json
      elsif self.deliverable_type == "Address"
        _arr[:address] = self.bill.deliverable.as_json
        _arr[:customer] = self.bill.deliverable.customer.as_json
        _arr[:profile] = self.bill.deliverable.customer.profile.as_json if self.bill.deliverable.customer.present?
      elsif self.deliverable_type == "Resource"
        _arr[:resource] = self.bill.deliverable.as_json
      elsif self.deliverable_type == "Section"
        _arr[:section] = self.bill.deliverable.as_json   
      end 
    end       
    _delivarable.push(_arr)                     
    _delivarable = JSON.generate(_delivarable)
    self.update_attribute(:deliverable,_delivarable)
  end
end

