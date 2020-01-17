class Sort < ActiveRecord::Base
  paginates_per 15
  resourcify

  attr_accessible :description, :name, :unit_id, :tab_ip, :port_no, :kot_print

  # => Model Associations
  belongs_to :unit
  has_many :order_details
  has_many :printers, as: :assignable

  # => Model Validations
  validates :name, :presence => true
  # validates :unit_id, :presence => true
  validates :tab_ip, allow_nil: true, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex), message: "%{value} is reserved." }


  # => Model scopes
  scope :current_unit_sorts, lambda {|unit_id|where(["unit_id=?", unit_id])}
  #
  def self.add_tab_ip(sort_id, tab_ip)
    self.find(sort_id).update_attributes(:tab_ip => tab_ip)
  end

  def self.get_table_orders(unit_id,status_ids)
    order_array = Array.new
    if status_ids.present?
      orders = Order.check_order_unit(unit_id).where('deliverable_type=? AND Date(created_at)=? AND billed=? AND trash=?',"Table",Date.today,0,0).check_order_status(status_ids)
    else  
      orders = Order.check_order_unit(unit_id).where('deliverable_type=? AND Date(created_at)=? AND billed=? AND trash=?',"Table",Date.today,0,0)
    end
    orders.each do |order|
      hash = {}
      hash[:order_id]         = order[:id]
      hash[:order_status_id]  = order[:order_status_id]
      hash[:order_subtotal]   = order[:order_subtotal]
      hash[:order_time]       = order[:created_at].strftime("%I:%M %P")
      hash[:deliverable_id]   = order[:deliverable_id]
      hash[:deliverable_type] = order[:deliverable_type]
      hash[:approved_orders]  = order.order_details.where('status=?',"approved").count
      hash[:preparing_orders] = order.order_details.where('status=?',"preparing").count
      hash[:prepared_orders]  = order.order_details.where('status=?',"prepared").count
      hash[:waiter_id]        = order.consumer[:id]
      hash[:waiter_name]      = order.consumer.profile[:firstname] +" "+ order.consumer.profile[:lastname]
      hash[:table_id]         = order.deliverable.id
      hash[:table_name]       = order.deliverable.name
      hash[:table_status]     = order.deliverable.status
      hash[:trash]            = order.trash
      order_details           = order.order_details
      details_array = Array.new
      order_details.each do |order_detail|
        details_hash = {}
        details_hash[:product_id]       = order_detail[:product_id]
        details_hash[:product_name]     = order_detail[:product_name]
        details_hash[:status]           = order_detail[:status]
        details_hash[:quantity]         = order_detail[:quantity]
        details_hash[:order_item_time]  = order_detail[:created_at].strftime("%I:%M %P")
        details_hash[:sort_id]          = order_detail[:sort_id]
        details_hash[:source]           = "table"
        details_hash[:item_preference]  = order_detail[:item_preference]
        details_hash[:trash]            = order_detail[:trash]
        details_hash[:order_details_id] = order_detail[:id]
        details_array.push details_hash
      end
      hash[:order_details]    = details_array
      order_array.push hash
    end
    return order_array
  end

  def self.get_resource_orders(unit_id,status_ids)
    order_array = Array.new
    if status_ids.present?
      orders = Order.check_order_unit(unit_id).where('deliverable_type=? AND Date(created_at)=? AND billed=? AND trash=?',"Resource",Date.today,0,0).check_order_status(status_ids)
    else  
      orders = Order.check_order_unit(unit_id).where('deliverable_type=? AND Date(created_at)=? AND billed=? AND trash=?',"Resource",Date.today,0,0)
    end
    orders.each do |order|
      hash = {}
      hash[:order_id]         = order[:id]
      hash[:order_sr_no]      = order[:order_sr_no]
      hash[:order_status_id]  = order[:order_status_id]
      hash[:order_subtotal]   = order[:order_subtotal]
      hash[:order_time]       = order[:created_at].strftime("%I:%M %P")
      hash[:deliverable_id]   = order[:deliverable_id]
      hash[:deliverable_type] = order[:deliverable_type]
      hash[:approved_orders]  = order.order_details.where('status=?',"approved").count
      hash[:preparing_orders] = order.order_details.where('status=?',"preparing").count
      hash[:prepared_orders]  = order.order_details.where('status=?',"prepared").count
      hash[:waiter_id]        = order.consumer[:id]
      hash[:waiter_name]      = order.consumer.profile[:firstname] +" "+ order.consumer.profile[:lastname]
      hash[:table_id]         = order.deliverable.id
      hash[:table_name]       = order.deliverable.name
      hash[:table_status]     = order.deliverable.status
      order_details           = order.order_details
      details_array = Array.new
      order_details.each do |order_detail|
        details_hash = {}
        details_hash[:product_id]       = order_detail[:product_id]
        details_hash[:product_name]     = order_detail[:product_name]
        details_hash[:status]           = order_detail[:status]
        details_hash[:quantity]         = order_detail[:quantity]
        details_hash[:order_item_time]  = order_detail[:created_at].strftime("%I:%M %P")
        details_hash[:sort_id]          = order_detail[:sort_id]
        details_hash[:source]           = "table"
        details_hash[:item_preference]  = order_detail[:item_preference]
        details_hash[:order_details_id] = order_detail[:id]
        details_array.push details_hash
      end
      hash[:order_details]    = details_array
      order_array.push hash
    end
    return order_array
  end

  def self.get_home_orders(unit_id,status_ids)
    order_array = Array.new
    if status_ids.present?
      orders = Order.check_order_unit(unit_id).where('Date(created_at)=? AND deliverable_type=?',Date.today,"Address").check_order_status(status_ids)
    else
      orders = Order.check_order_unit(unit_id).where('Date(created_at)=? AND deliverable_type=?',Date.today,"Address")
    end  
    orders.each do |order|
      hash = {}
      hash[:order_id]         = order[:id]
      hash[:order_sr_no]      = order[:order_sr_no]
      hash[:order_status_id]  = order[:order_status_id]
      hash[:order_subtotal]   = order[:order_subtotal]
      hash[:order_time]       = order[:created_at].strftime("%I:%M %P")
      hash[:source]           = order[:source]
      hash[:deliverable_id]   = order[:deliverable_id]
      hash[:deliverable_type] = order[:deliverable_type]
      hash[:approved_orders]  = order.order_details.where('status=?',"approved").count
      hash[:preparing_orders] = order.order_details.where('status=?',"preparing").count
      hash[:prepared_orders]  = order.order_details.where('status=?',"prepared").count
      order_details           = order.order_details
      details_array = Array.new
      order_details.each do |order_detail|
        details_hash = {}
        details_hash[:product_id]       = order_detail[:product_id]
        details_hash[:product_name]     = order_detail[:product_name]
        details_hash[:status]           = order_detail[:status]
        details_hash[:quantity]         = order_detail[:quantity]
        details_hash[:order_item_time]  = order_detail[:created_at].strftime("%I:%M %P")
        details_hash[:sort_id]          = order_detail[:sort_id]
        details_hash[:source]           = "non-table"
        details_hash[:item_preference]  = order_detail[:item_preference]
        details_hash[:order_details_id] = order_detail[:id]
        details_array.push details_hash
      end
      hash[:order_details]    = details_array
      order_array.push hash
    end
    return order_array
  end

  def self.get_section_orders(unit_id,status_ids)
    order_array = Array.new
    if status_ids.present?
      orders = Order.check_order_unit(unit_id).where('Date(created_at)=? AND deliverable_type=?',Date.today,"Section").check_order_status(status_ids)
    else
      orders = Order.check_order_unit(unit_id).where('Date(created_at)=? AND deliverable_type=?',Date.today,"Section")
    end  
    orders.each do |order|
      hash = {}
      hash[:order_id]         = order[:id]
      hash[:order_sr_no]      = order[:order_sr_no]
      hash[:order_status_id]  = order[:order_status_id]
      hash[:order_subtotal]   = order[:order_subtotal]
      hash[:order_time]       = order[:created_at].strftime("%I:%M %P")
      hash[:source]           = order[:source]
      hash[:deliverable_id]   = order[:deliverable_id]
      hash[:deliverable_type] = order[:deliverable_type]
      hash[:approved_orders]  = order.order_details.where('status=?',"approved").count
      hash[:preparing_orders] = order.order_details.where('status=?',"preparing").count
      hash[:prepared_orders]  = order.order_details.where('status=?',"prepared").count
      hash[:waiter_id]        = order.consumer[:id]
      hash[:waiter_name]      = order.consumer.profile[:firstname] +" "+ order.consumer.profile[:lastname]
      order_details           = order.order_details
      details_array = Array.new
      order_details.each do |order_detail|
        details_hash = {}
        details_hash[:product_id]       = order_detail[:product_id]
        details_hash[:product_name]     = order_detail[:product_name]
        details_hash[:status]           = order_detail[:status]
        details_hash[:quantity]         = order_detail[:quantity]
        details_hash[:order_item_time]  = order_detail[:created_at].strftime("%I:%M %P")
        details_hash[:sort_id]          = order_detail[:sort_id]
        details_hash[:source]           = "non-table"
        details_hash[:item_preference]  = order_detail[:item_preference]
        details_hash[:order_details_id] = order_detail[:id]
        details_array.push details_hash
      end
      hash[:order_details]    = details_array
      order_array.push hash
    end
    return order_array
  end

  def self.get_pickup_orders(unit_id,status_ids)
    order_array = Array.new
    if status_ids.present?
      orders = Order.check_order_unit(unit_id).where('Date(created_at)=? AND deliverable_type=?',Date.today,"Customer").check_order_status(status_ids)
    else
      orders = Order.check_order_unit(unit_id).where('Date(created_at)=? AND deliverable_type=?',Date.today,"Customer")
    end
    orders.each do |order|
      hash = {}
      hash[:order_id]         = order[:id]
      hash[:order_sr_no]      = order[:order_sr_no]
      hash[:order_status_id]  = order[:order_status_id]
      hash[:order_subtotal]   = order[:order_subtotal]
      hash[:order_time]       = order[:created_at].strftime("%I:%M %P")
      hash[:source]           = order[:source]
      hash[:deliverable_id]   = order[:deliverable_id]
      hash[:deliverable_type] = order[:deliverable_type]
      hash[:approved_orders]  = order.order_details.where('status=?',"approved").count
      hash[:preparing_orders] = order.order_details.where('status=?',"preparing").count
      hash[:prepared_orders]  = order.order_details.where('status=?',"prepared").count
      hash[:customer_id]      = order.deliverable[:id]
      hash[:customer_name]    = order.deliverable.profile[:firstname]+" "+order.deliverable.profile[:lastname] if order.deliverable.profile.present?
      hash[:customer_mobile]  = order.deliverable[:mobile_no]
      order_details           = order.order_details
      details_array = Array.new
      order_details.each do |order_detail|
        details_hash = {}
        details_hash[:product_id]       = order_detail[:product_id]
        details_hash[:product_name]     = order_detail[:product_name]
        details_hash[:status]           = order_detail[:status]
        details_hash[:quantity]         = order_detail[:quantity]
        details_hash[:order_item_time]  = order_detail[:created_at].strftime("%I:%M %P")
        details_hash[:sort_id]          = order_detail[:sort_id]
        details_hash[:source]           = "non-table"
        details_hash[:item_preference]  = order_detail[:item_preference]
        details_hash[:order_details_id] = order_detail[:id]
        details_array.push details_hash
      end
      hash[:order_details]    = details_array
      order_array.push hash
    end
    return order_array
  end

end
