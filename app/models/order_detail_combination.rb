class OrderDetailCombination < ActiveRecord::Base
  attr_accessible :combination_qty, :menu_product_combination_id, :order_detail_id, :total_price, :product_id, :product_name, :product_price, :unit_id, :status,:is_stock_debited, :material_cost,:product_unique_identity

  belongs_to :order_detail
  belongs_to :product
  belongs_to :menu_product_combination
  #has_one :combination_type, through: :menu_product_combination

  STATUSES = %w(approved preparing prepared deivered canceled) # Always maintain it's serial order for priority
  after_create :update_item_prices, :set_attributes

  ### => Model Delegations
  delegate  :id, :order_id, :product_id, :unit_id, :menu_product_id,
            :to => :order_detail,
            :prefix => true

  delegate  :ammount, :product_id, :combinations_rule, :product_unit_id,
            :to => :menu_product_combination,
            :prefix => 'customization'            

  # => Model scopes
  scope :set_unit,                     lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :set_menu_product_combination, lambda {|mp_id|where(["menu_product_combination_id=?", mp_id])}
  scope :status_not_equals,            lambda {|status|where(["status !=?", status])}
  scope :status_not_in,                lambda {|statuses|where(["status NOT IN (?)", statuses])}
  scope :stock_not_debited,            lambda { where(["is_stock_debited !=(?)",'yes']) }
  scope :by_product,                   lambda {|product|where(["product_id=?", product])}
  scope :by_unique_identity,           lambda {|product_unique_identity| where(:product_unique_identity=>product_unique_identity)}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('status')        
        self.status = "approved"
      end          
      self.product_id = self.menu_product_combination.product_id
      self.product_price = self.menu_product_combination.price
      self.product_name = self.menu_product_combination.product.name
      self.is_stock_debited = "no"
      if !initialized.key?('product_unique_identity')
         self.product_unique_identity = nil
      end 
    end
  end

  def update_item_prices
    update_customization_cost!
  end

  def set_attributes
    update_attribute(:unit_id, self.order_detail.order_unit_id)
  end

  def update_customization_cost!
    update_attribute(:total_price, item_total_price)
    self.order_detail.update_column(:customization_price, self.total_price)
  end

  def item_total_price
    self.product_price.to_f * self.combination_qty.to_f
  end  

  def inventory_compatible_quantity product_unit_id,amount,order_quantity, combination_quantity
    amount.to_f* order_quantity.to_f * combination_quantity.to_f * (ProductUnit.find(product_unit_id)).multiplier.to_f
  end

  def stock_on_hold product_id, unit_id
    quantity = OrderDetailCombination.set_unit(unit_id).by_product(product_id).stock_not_debited.sum :combination_qty
    inventory_compatible_quantity self.customization_product_unit_id,self.customization_ammount,quantity
  end

  def stock_issued! cost
    update_attributes(:material_cost => cost, :is_stock_debited => 'yes')
  end
  
  def self.save_order_details_combinations(order_details, menu_product_combination_id, combination_qty, total_price,unit_id)
    mp_combination = MenuProductCombination.find(menu_product_combination_id)
    _total_price = mp_combination.price * combination_qty
    order_details.order_detail_combinations.create( :menu_product_combination_id => mp_combination.id,
                                                    :combination_qty => combination_qty,
                                                    :total_price => _total_price,
                                                    :product_id => mp_combination.product.id,
                                                    :product_name => mp_combination.product.name,
                                                    :product_price => mp_combination.price,
                                                    :unit_id => unit_id, :status => order_details.status)
    return _total_price
  end  
end
