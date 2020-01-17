class ReturnItem < ActiveRecord::Base
	attr_accessible :bill_id, :unit_id, :order_detail_id, :price, :product_id, :quantity, :remarks, :store_id, :added_to_stock, :cashback_mode, :business_type, :sku, :color_name, :size, :model_number, :sell_price_without_tax, :user_id, :device_id, :refund_mode, :refund_status, :order_id, :return_status_id, :picked_by

	belongs_to	:bill
	belongs_to	:product
	belongs_to	:order_detail
  belongs_to  :store
  belongs_to  :user
  belongs_to  :order
	has_many    :stocks, as: :transaction
  belongs_to  :delivery_boy
  belongs_to  :order_status, :foreign_key => :return_status_id

  #Model scope
  scope :by_bill_id, lambda {|bill_id|where(["bill_id = ?", bill_id])}
  scope :stock_not_added, lambda {where(["added_to_stock = ?",'False'])} 
  scope :by_store, lambda {|store_id|where(["store_id = ?",store_id])}
  scope :unit_return, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :unit_return_dboy, lambda {|unit_id|where(["return_items.unit_id=? AND return_items.delivery_boy_id IS NULL", unit_id])}
  scope :by_date_range, lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
	scope :set_device, lambda {|device_id| where(["device_id=?", device_id])}
  scope :wallet_return, lambda {where(["refund_mode = ?",'wallet'])} 
  scope :cash_return, lambda {where(["refund_mode = ?",'cash'])}
  # scope :card_return, lambda {where(["refund_mode = ?",'card'])} 
  scope :by_delivery_boy, lambda {|delivery_boy_id| where(["delivery_boy_id = ?",delivery_boy_id])}
  scope :by_return_status, lambda {|return_status_id| where(["return_status_id = ?",return_status_id])}

  def self.add_return_items(bill_id,order_detail_id,price,product_id,quantity,remarks,unit_id,store_id,deliverable_id,deliverable_type,return_price,is_refandable,cashback_mode,stock_status,device_id='',user_id='',refund_mode='',refund_status='')
    order_details = OrderDetail.find(order_detail_id)
    sell_price_without_tax = order_details.unit_price_without_tax
    return_item = ReturnItem.new
    return_item[:bill_id]                = bill_id
    return_item[:unit_id]                = unit_id
    return_item[:order_detail_id]        = order_detail_id
    return_item[:order_id]               = order_details.order_id
    return_item[:price]                  = return_price
    return_item[:product_id]             = product_id
    return_item[:quantity]               = quantity
    return_item[:remarks]                = remarks
    return_item[:store_id]               = store_id
    return_item[:cashback_mode]          = cashback_mode
    return_item[:business_type]          = Product.find(product_id).business_type
    return_item[:sku]                    = order_details.product_unique_identity  
    return_item[:sell_price_without_tax] = sell_price_without_tax
    return_item[:device_id]              = device_id
    return_item[:user_id]                = user_id
    return_item[:refund_status]          = refund_status
    return_item[:refund_mode]            = refund_mode 
    return_item[:return_status_id]       = 1 # Return Item Initiated 
    if order_details.lot.present?
      stock = order_details.lot  
      return_item[:color_name]      = stock.color_name
      return_item[:size]            = stock.size_name
      return_item[:model_number]    = stock.model
      return_item[:expiry_date]     = stock.expiry_date
      stock_qty = stock.stock_qty + quantity
      stock.update_attributes(:stock_qty => stock_qty)
    end  
    return_item.save
    order_details.update_attributes(:is_returned => true, :return_qty => quantity, :is_refandable => is_refandable)
    if stock_status == "true"
      _stock = Stock.save_stock(product_id,order_details.store_id,price,quantity,return_item.id,"return_item",quantity,0,return_item.expiry_date,return_item.sku,nil,return_item.model_number,return_item.size,return_item.color_name,sell_price_without_tax)
      StockPrice.add_stock_price(_stock.id, price, price, product_id, price, 0, 0, price, 0,0,0,sell_price_without_tax)
      return_item.update_attributes(:added_to_stock => true)
    else
      _stock = Stock.save_stock(product_id,store_id,price,quantity,return_item.id,"return_item",quantity,0,return_item.expiry_date,return_item.sku,nil,return_item.model_number,return_item.size,return_item.color_name,sell_price_without_tax)
      StockPrice.add_stock_price(_stock.id, price, price, product_id, price, 0, 0, price, 0,0,0,sell_price_without_tax)  
      return_item.update_attributes(:added_to_stock => false)
    end    
    customer = CustomerWallet.where( :customer_id => deliverable_id )
    customer_wallet = CustomerWallet.new
    if deliverable_type == "Customer"
      if customer.length == 0
        customer_wallet[:customer_id]       = deliverable_id
        customer_wallet[:credited_amount]   = return_price
        customer_wallet[:return_item_id]    = return_item.id
        customer_wallet[:available_amount]  = return_price
        customer_wallet[:expiry_date]       = Date.today + 1.year
        customer_wallet.save
      else
        customer_wallet[:customer_id]       = deliverable_id
        customer_wallet[:credited_amount]   = return_price
        customer_wallet[:return_item_id]    = return_item.id
        customer_wallet[:available_amount]  = customer.last[:available_amount].to_f + return_price.to_f
        customer_wallet[:expiry_date]       = Date.today + 1.year
        customer_wallet.save
      end  
    end
    return return_item		
	end	

  # Data export to CSV
  def self.by_date_return_item_reports_to_csv(user_unit_id,unit_id,return_items,from_datetime,to_datetime)
    CSV.generate do |csv|
      _pref = ["bill_id","product name","price","quantity","sku","Total Price","Refund Mode","customer name","remarks","added_to_stock"]
      _pref_humanize =  _pref.map{|x| (x.humanize)}
      csv << _pref_humanize
      _total_price = 0
      return_items.each do |return_item|
        _total_price = _total_price + (return_item.price.to_f * return_item.quantity.to_f)
        _row = Array.new
        _row.push(return_item.bill_id)
        _row.push(return_item.product.name)
        _row.push(return_item.price)
        _row.push(return_item.quantity)
        _row.push(return_item.sku.present? ? "#{return_item.sku}" : "_")
        _row.push(return_item.price.to_f * return_item.quantity.to_f)
        _row.push(return_item.refund_mode)
        if return_item.bill.customer.present?
          if return_item.bill.customer.customer_profile.customer_name.present?
            _row.push(return_item.bill.customer.customer_profile.customer_name)
          else
            _row.push("#{return_item.bill.customer.customer_profile.firstname} "" #{return_item.bill.customer.customer_profile.lastname}")
          end  
        else
          _row.push("....")
        end  
        _row.push(return_item.remarks)
        _row.push(return_item.added_to_stock? ? "true" : "false")
        csv << _row
      end
      _blank = Array.new
      _blank.push
      csv<<_blank
      _totalpref = ["Total price","Total quantity"]
      csv << _totalpref
      _totalpref = Array.new
      _totalpref.push _total_price
      _totalpref.push return_items.sum(:quantity)
      _totalpref_humanize =  _totalpref.map{|x| (x)}
      csv << _totalpref_humanize
    end
  end
	
  def self.save_assign_return(data)
    parsed_json = JSON.parse(data)
    parsed_json.each do |delivery_boy_id, returns_array|
      if returns_array.any?
        returns_array.each do |return_id|
          @return = ReturnItem.find(return_id)
          @return = @return.update_attribute(:delivery_boy_id, delivery_boy_id)
        end
      end
    end

    return @return
  end

  def self.refund_money _return_item, _account_no = '', _ifsc_code = ''
    if _return_item.order_detail.is_refandable.present? && _return_item.order_detail.is_refandable == 'yes'
      amount = _return_item.order_detail.subtotal
      MoneyRefund.create(:customer_id => _return_item.order.customer_id, :order_id => _return_item.order_id, :refund_amount => amount, :account_no => _account_no, :ifsc_code => _ifsc_code)
    end
  end
end
