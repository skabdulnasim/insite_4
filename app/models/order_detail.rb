class OrderDetail < ActiveRecord::Base
  # Accessable attributes
  attr_accessible :order_id, :menu_product_id, :quantity, :sort_id, :status, :preferences, :cancel_cause, :trash, :parcel,
                  :bill_status, :product_id, :product_name, :procurement_cost, :product_price, :customization_price,
                  :unit_price_without_tax, :tax_amount, :tax_details, :unit_price_with_tax, :discount, :subtotal, :unit_id,
                  :is_stock_debited, :material_cost, :remarks, :order_detail_combinations_attributes,:order_details_combos_attributes, :product_unique_identity,
                  :menu_product_category_id, :weight, :product_unit_id, :store_id, :is_returned, :expiry_date, :properties, 
                  :hsn_code, :lot_id, :slot_id, :stock_id, :checksum, :sale_rule_id, :discount_detail, :section_id, :item_status, :discount_percentage, :recorded_at, :delivery_status, :color_name, :size_name, :lot_desc, :bill_destination_id, :delivary_date, :item_remarks, :is_refund, :is_refandable, :return_qty, :item_preference


  STATUSES = %w(New approved preparing prepared delivered canceled future_order estimate preorder picked)


  ### => Model relations
  belongs_to :order, inverse_of: :order_details
  belongs_to :product
  belongs_to :menu_product
  belongs_to :sort
  belongs_to :sold_item_unit, :class_name => "ProductUnit", :foreign_key => :product_unit_id
  has_many :order_detail_combinations
  has_many :order_details_combos
  has_many :stocks, as: :stock_transaction
  belongs_to :lot
  belongs_to :slot
  belongs_to :store
  
  accepts_nested_attributes_for :order_detail_combinations, allow_destroy: true
  accepts_nested_attributes_for :order_details_combos, allow_destroy: true

  ### => Model Validations
  # validates :status          , :presence => true,
  #                              :inclusion => { :in => STATUSES }
  # validates :menu_product_id , :presence => true
  # validates :quantity        , :presence => true
  # validates :sort_id         , :presence => true
  # validates :trash           , :presence => true
  # validates :product_id      , :presence => true
  # validates :product_name    , :presence => true

  # => Model Callbacks
  before_save   :set_dynamic_item_attributes

  before_update :apply_no_charge,
                :apply_item_discount
                :update_user_sale
                  
  after_create  :set_attributes,
                :set_user_sale,
                :set_store_id_to_order
  after_save    :change_order_status_on_order_details_status,
                :update_order_for_cancled_item              

  after_save    :issue_stock, if: :item_in_state_to_issue_stock?
  after_update  :update_order_detail_combinations_status,
                :update_order_for_no_charge,
                :update_order_prices,
                :update_bill,
                :push_update_to_subscribers,
                :update_order_for_is_stock_debited
  #after_commit  :update_order_for_stock_status
  after_update  :update_order_for_return_item, if: :is_returned_changed?
  after_update :update_bill_for_return_item, if: :is_returned_changed?  
  after_update :push_update_to_subscribers_for_cancle_item, if: :trash_changed?   
  ### => Model Delegations
  delegate  :id, :product_id, :unit_id, :menu_product_id,
            :to => :order,
            :prefix => true

  delegate  :name, :basic_unit,
            :to => :product,
            :prefix => 'item'

  delegate  :product_id, :store_id, :sort_id, :sell_price, :sell_price_without_tax, :procured_price, :is_buffet_product, :tax_group_id,
            :to => :menu_product,
            :prefix => 'menu_item'

  scope :check_order_details_sort,     lambda {|sort_id|where(["sort_id =(?)", sort_id])}
  scope :check_order_details_status,   lambda {|status|where(["status =(?)", status])}
  scope :today,                        lambda {joins(:order).where("DATE(orders.delivary_date) =?", Date.today)}
  scope :ordered_today,                lambda { where(["created_at > ?",Time.zone.now.beginning_of_day]) }
  scope :set_unit,                     lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :set_unit_in,                  lambda {|unit_ids|where(["unit_id in (?)", unit_ids])}
  scope :set_menu_product,             lambda {|mp_id|where(["menu_product_id=?", mp_id])}
  scope :status_not_equals,            lambda {|status|where(["status !=?", status])}
  scope :status_not_in,                lambda {|statuses|where(["status NOT IN (?)", statuses])}
  scope :stock_not_debited,            lambda { where(["is_stock_debited !=(?)",'yes']) }
  scope :by_product,                   lambda {|product|where(["product_id=?", product])}
  scope :by_date_range,                lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :order_detail_by_date,         lambda {|from_date, upto_date|where('date(created_at) BETWEEN ? AND ?',from_date,upto_date)}
  scope :by_unique_identity,           lambda {|product_unique_identity| where(:product_unique_identity=>product_unique_identity)}
  scope :cancel_item,                  lambda { where (["trash=?", 1]) }
  scope :valid_item,                   lambda {where (["trash=?", 0])} 
  scope :by_lot_id,                    lambda {|lot_id| where(["lot_id=?", lot_id])}
  scope :by_order_ids,                 lambda {|order_ids| where(["order_id in (?)",order_ids])} 
  scope :by_status,                    lambda {|status| where('status=?',status)}
  scope :by_delivery_date,             lambda {|delivary_date|where(["date(delivary_date)=?", delivary_date])}
  scope :by_slot,                      lambda {|slot_id|where("slot_id=?",slot_id)}
  scope :by_store,                     lambda{|store_id|where("store_id=?",store_id)} 
  scope :by_recorded_at,               lambda{|from_date,to_date|where("recorded_at BETWEEN ? AND ?",from_date,to_date)}
  scope :by_product_id,                lambda {|product_id| where(["product_id = ?",product_id])}
  scope :by_recorded_at_year,          lambda {|year|where(["extract(year from recorded_at)=?", year])}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('status')
        self.status = "approved"
      end
      if !initialized.key?('trash')
        self.trash = 0
      end
      if !initialized.key?('parcel')
        self.parcel = 0
      end
      if !initialized.key?('discount')
        self.discount = 0
      end
      if !initialized.key?('discount_percentage')
        self.discount_percentage = 0
      end
      if !initialized.key?('return_qty')
        self.return_qty = 0
      end
      if !initialized.key?('hsn_code')
        if self.menu_product.product.hsn_code.present?
          self.hsn_code = self.menu_product.product.hsn_code
        else
          self.hsn_code = ''
        end 
      end  
      if !initialized.key?('product_unique_identity')
         self.product_unique_identity = nil
      elsif self.product_unique_identity == ''
         self.product_unique_identity = nil
      end
      if !initialized.key?('weight')
         self.weight = nil
      end 
      if !initialized.key?('delivery_status')
         self.delivery_status = 0
      end  
      self.section_id = self.menu_product.menu_card.section_id
      self.product_id = self.menu_product.product_id
      self.product_name = self.menu_product.product_name
      self.sort_id = self.menu_product.sort_id
      # self.store_id = self.menu_product.store_id
      if !initialized.key?('store_id')
        self.store_id = self.menu_product.store_id
      end
      self.menu_product_category_id = self.menu_product.menu_category_id
      self.is_stock_debited = "no"
      self.bill_destination_id = self.menu_product.bill_destination_id
      self.is_refund = 'no'
    end
  end

  # Setting item pricing attributes for both catalog and non-catalog items
  def set_dynamic_item_attributes
    self.customization_price = self.order_detail_combinations.present? ? (self.order_detail_combinations.sum :total_price) : 0
    self.recorded_at = self.order.recorded_at
    self.delivary_date = self.order.delivary_date
    self.slot_id = self.order.order_slots.first.slot_id if self.order.order_slots.present?
    if is_uniquely_identifiable_item?
      if is_uniquely_identifiable_item? and self.lot_id.present?
        #_stock = valid_lot_item_stock
        # if _stock.present?
        #   raise I18n.t(:error_invalid_sku, sku: self.product_unique_identity) if self.quantity > _stock.stock_qty
        # else
        #   raise I18n.t("Stock Mismatch for lot :#{self.lot_id}, Sku:#{self.product_unique_identity},Product:#{self.product_id}")
        # end  
        if self.product.by_catalog? and self.lot_id.present?
          lot = Lot.find(self.lot_id)
          if new_record?
            self.procurement_cost = lot.procured_price
            self.product_price = lot.sell_price_without_tax
            self.customization_price = self.order_detail_combinations.present? ? (self.order_detail_combinations.sum :total_price) : 0
          end  
          self.unit_price_without_tax = item_unit_price_without_tax
          #self.unit_price_without_tax = item_unit_price_without_tax.round(2)
          set_item_taxes
          self.unit_price_with_tax = item_unit_price_with_tax
          self.subtotal = item_subtotal 
          #self.stock_id = lot.stock_id
          self.color_name = lot.color_name
          self.size_name = lot.size_name
          self.lot_desc = lot.lot_desc
        end  
      else  
        _stock = valid_item_stock
        raise I18n.t(:error_invalid_sku, sku: self.product_unique_identity) unless _stock.present?
        _sellable_quantity = self.product.by_bulk_weight? ? self.weight : self.quantity
        self.unit_price_with_tax = _stock.sell_price_of_item _sellable_quantity
        self.weight = self.product.by_bulk_weight? ? self.weight : _stock.weight
        if self.product.by_catalog?
          self.product_unit_id = _stock.received_product_unit
          self.procurement_cost = self.menu_product.procured_price
          self.product_price = self.menu_product.sell_price_without_tax
          self.customization_price = self.order_detail_combinations.present? ? (self.order_detail_combinations.sum :total_price) : 0
          self.unit_price_without_tax = item_unit_price_without_tax
          set_item_taxes
          self.unit_price_with_tax = item_unit_price_with_tax
          self.subtotal = item_subtotal
        else
          self.product_unit_id = self.product.by_mrp? ? _stock.received_product_unit : self.product.product_compositions.first.raw_product_unit
          self.procurement_cost = (_stock.price / _stock.stock_credit.to_f) * self.quantity
          self.product_price = item_price_from_unit_price_with_tax
          self.unit_price_without_tax = item_unit_price_without_tax
          set_item_taxes
          self.subtotal = self.product.by_bulk_weight? ? self.unit_price_with_tax : item_subtotal
        end  
      end
    else
      self.procurement_cost = self.menu_product.procured_price
      self.product_price = self.menu_product.sell_price_without_tax
      self.customization_price = self.order_detail_combinations.present? ? (self.order_detail_combinations.sum :total_price) : 0
      self.unit_price_without_tax = item_unit_price_without_tax
      set_item_taxes
      self.unit_price_with_tax = item_unit_price_with_tax
      self.subtotal = item_subtotal
    end
  end

  # Calculate and set item price for single unit (without tax)
  def item_price_from_unit_price_with_tax
    #((self.unit_price_with_tax * 100)/(100+self.menu_product.tax_group.total_amnt.to_f)).round(2)
    ((self.unit_price_with_tax * 100)/(100+self.menu_product.tax_group.total_amnt.to_f))
  end

  # Calculate and set item price for single unit (without tax)
  def item_unit_price_without_tax
    if AppConfiguration.get_config_value('discount_on_item') == 'enabled'
      self.customization_price + self.product_price - self.discount
    else
      self.customization_price + self.product_price
    end  
  end

  # Calculate and set item price for single unit (with tax)
  def item_unit_price_with_tax
    self.unit_price_without_tax + self.tax_amount
  end

  def discount_with_out_tax
    self.discount + self.tax_amount
  end

  # Calculate item subtotal
  def item_subtotal
    if AppConfiguration.get_config_value('discount_on_item') == 'enabled'
      #(self.unit_price_with_tax * self.quantity).round(2)
      self.unit_price_with_tax * self.quantity
    else  
      (self.unit_price_with_tax * self.quantity)
      #((self.unit_price_with_tax * self.quantity) - self.discount).round(2)
    end  
  end

  # Calculate and set tax attributes
  def set_item_taxes total_tax=0,tax_array=[]
    tem_array = Array.new
    @price_with_service_tax = self.unit_price_without_tax
    @service_array = self.menu_product.tax_group.tax_classes
    @service_array.sort { |a, b|  a.ammount <=> b.ammount }
    @service_array.map { |e| tem_array.push e if e.tax_type == "service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "tax_on_service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "parcel_charge"}
    @service_arr= tem_array | @service_array
    if self.menu_product.menu_card.operation_type == "b2b"
      if self.order.customer.present?
        business_gstin = self.order.unit.unit_detail.options[:gst_code]
        customer_gstin = self.order.customer.gstin
        if business_gstin[0..1] != customer_gstin[0..1] 
          i = 1
          @service_arr.each do |tc|
            if tc.operation_type == 'igst'
              if AppConfiguration.get_config_value('variable_tax') == 'enabled'
                _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
                tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                total_tax += _tax_amount
                tax_array.push(tax_details)
              elsif AppConfiguration.get_config_value('aply_tax_on_menu_item') == 'enabled'
                if tc.tax_type == "service"
                  @price_with_service_tax = 0
                  @price_with_service_tax = self.unit_price_without_tax
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  #total_tax += _tax_amount.round(2)
                  total_tax += _tax_amount
                  @service_tax = total_tax
                  @price_with_service_tax = self.unit_price_without_tax + _tax_amount
                  tax_array.push(tax_details)
                elsif tc.tax_type == "tax_on_service"
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @service_tax.to_f) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  #total_tax += _tax_amount.round(2)
                  total_tax += _tax_amount
                  tax_array.push(tax_details)  
                elsif tc.tax_type == "tax_on_item_price"
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  #total_tax += _tax_amount.round(2)
                  tax_array.push(tax_details) 
                elsif tc.tax_type == "parcel_charge"
                  @price_with_service_tax = 0
                  @price_with_service_tax = self.unit_price_without_tax
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  #total_tax += _tax_amount.round(2)
                  total_tax += _tax_amount
                  @service_tax = total_tax
                  @price_with_service_tax = self.unit_price_without_tax + _tax_amount
                  tax_array.push(tax_details)    
                else
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax.to_f) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  #total_tax += _tax_amount.round(2)
                  tax_array.push(tax_details)
                end
              else
                _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
                tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                total_tax += _tax_amount
                tax_array.push(tax_details)  
              end 
              i += 1
            end
          end
        else
          i = 1
          @service_arr.each do |tc|
            if tc.operation_type != 'igst'
              if AppConfiguration.get_config_value('variable_tax') == 'enabled'
                _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
                tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                total_tax += _tax_amount
                tax_array.push(tax_details)
              elsif AppConfiguration.get_config_value('aply_tax_on_menu_item') == 'enabled'
                if tc.tax_type == "service"
                  @price_with_service_tax = 0
                  @price_with_service_tax = self.unit_price_without_tax
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  #total_tax += _tax_amount.round(2)
                  total_tax += _tax_amount
                  @service_tax = total_tax
                  @price_with_service_tax = self.unit_price_without_tax + _tax_amount
                  tax_array.push(tax_details)
                elsif tc.tax_type == "tax_on_service"
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @service_tax.to_f) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  #total_tax += _tax_amount.round(2)
                  total_tax += _tax_amount
                  tax_array.push(tax_details)  
                elsif tc.tax_type == "tax_on_item_price"
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  #total_tax += _tax_amount.round(2)
                  tax_array.push(tax_details) 
                elsif tc.tax_type == "parcel_charge"
                  @price_with_service_tax = 0
                  @price_with_service_tax = self.unit_price_without_tax
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  #total_tax += _tax_amount.round(2)
                  total_tax += _tax_amount
                  @service_tax = total_tax
                  @price_with_service_tax = self.unit_price_without_tax + _tax_amount
                  tax_array.push(tax_details)    
                else
                  _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax.to_f) / 100) : tc.ammount.to_f
                  tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  #total_tax += _tax_amount.round(2)
                  tax_array.push(tax_details)
                end
              else
                _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
                tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
                total_tax += _tax_amount
                tax_array.push(tax_details)  
              end 
              i += 1
            end
          end
        end
      end    
    else
      i = 1
      _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
      @service_arr.each do |tc|
        if tc.operation_type != 'igst'
          if AppConfiguration.get_config_value('variable_tax') == 'enabled'
            if tc.tax_type == 'variable'
              if self.unit_price_without_tax <= _limit_vtax
                if i == 1
                  tax_classs = TaxClass.by_tax_type('variable').by_ammount(2.5)
                  tax_class = tax_classs[0]
                  _tax_amount = tax_class.percentage? ? ((tax_class.ammount.to_f * self.unit_price_without_tax) / 100) : tax_class.ammount.to_f
                  tax_details = {:tax_class_id => tax_class.id, :tax_class_name => tax_class.name, :tax_type => tax_class.tax_type, :tax_percentage => tax_class.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  tax_array.push(tax_details)
                elsif i == 2
                  tax_classs = TaxClass.by_tax_type('variable').by_ammount(2.5)
                  tax_class = tax_classs[-1]
                  _tax_amount = tax_class.percentage? ? ((tax_class.ammount.to_f * self.unit_price_without_tax) / 100) : tax_class.ammount.to_f
                  tax_details = {:tax_class_id => tax_class.id, :tax_class_name => tax_class.name, :tax_type => tax_class.tax_type, :tax_percentage => tax_class.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  tax_array.push(tax_details)
                end
              else
                if i == 3
                  if tc.ammount.to_f == 9.0 || tc.ammount.to_f == 9
                    tax_classs = TaxClass.by_tax_type('variable').by_ammount(9)
                  else  
                    tax_classs = TaxClass.by_tax_type('variable').by_ammount(6)
                  end  
                  tax_class = tax_classs[0]
                  _tax_amount = tax_class.percentage? ? ((tax_class.ammount.to_f * self.unit_price_without_tax) / 100) : tax_class.ammount.to_f
                  tax_details = {:tax_class_id => tax_class.id, :tax_class_name => tax_class.name, :tax_type => tax_class.tax_type, :tax_percentage => tax_class.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  tax_array.push(tax_details)
                elsif i == 4
                  if tc.ammount.to_f == 9.0 || tc.ammount.to_f == 9
                    tax_classs = TaxClass.by_tax_type('variable').by_ammount(9)
                  else  
                    tax_classs = TaxClass.by_tax_type('variable').by_ammount(6)
                  end 
                  tax_class = tax_classs[-1]
                  _tax_amount = tax_class.percentage? ? ((tax_class.ammount.to_f * self.unit_price_without_tax) / 100) : tax_class.ammount.to_f
                  tax_details = {:tax_class_id => tax_class.id, :tax_class_name => tax_class.name, :tax_type => tax_class.tax_type, :tax_percentage => tax_class.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  tax_array.push(tax_details)
                end
              end 
            else
              _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
              tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
              total_tax += _tax_amount
              tax_array.push(tax_details)  
            end  
          elsif AppConfiguration.get_config_value('aply_tax_on_menu_item') == 'enabled'
            if tc.tax_type == "service"
              @price_with_service_tax = 0
              @price_with_service_tax = self.unit_price_without_tax
              _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
              tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
              #total_tax += _tax_amount.round(2)
              total_tax += _tax_amount
              @service_tax = total_tax
              @price_with_service_tax = self.unit_price_without_tax + _tax_amount
              tax_array.push(tax_details)
            elsif tc.tax_type == "tax_on_service"
              _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @service_tax.to_f) / 100) : tc.ammount.to_f
              tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
              #total_tax += _tax_amount.round(2)
              total_tax += _tax_amount
              tax_array.push(tax_details)  
            elsif tc.tax_type == "tax_on_item_price"
              _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
              tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
              total_tax += _tax_amount
              #total_tax += _tax_amount.round(2)
              tax_array.push(tax_details) 
            elsif tc.tax_type == "parcel_charge"
              @price_with_service_tax = 0
              @price_with_service_tax = self.unit_price_without_tax
              _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
              tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
              #total_tax += _tax_amount.round(2)
              total_tax += _tax_amount
              @service_tax = total_tax
              @price_with_service_tax = self.unit_price_without_tax + _tax_amount
              tax_array.push(tax_details)    
            else
              _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax.to_f) / 100) : tc.ammount.to_f
              tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
              total_tax += _tax_amount
              #total_tax += _tax_amount.round(2)
              tax_array.push(tax_details)
            end   
          else
            _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
            tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
            total_tax += _tax_amount
            tax_array.push(tax_details)  
          end 
          i += 1
        end  
      end  
    end     
    
    #self.tax_amount = total_tax.round(2)
    self.tax_amount = total_tax
    self.tax_details = JSON.generate(tax_array)
  end

  def remove_service_charge total_tax=0,tax_array=[]
    tem_array = Array.new
    @price_with_service_tax = self.unit_price_without_tax
    @service_array = self.menu_product.tax_group.tax_classes
    @service_array.map { |e| tem_array.push e if e.tax_type == "service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "tax_on_service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "parcel_charge"}
    @service_arr= tem_array | @service_array
    @service_arr.each do |tc|
      if AppConfiguration.get_config_value('variable_tax') == 'enabled'
        if tc.tax_type == 'variable'
          if (tc.lower_limit..tc.upper_limit).include?(self.unit_price_without_tax)
            _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
            tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
            total_tax += _tax_amount
            tax_array.push(tax_details)
          end
        else
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          total_tax += _tax_amount
          tax_array.push(tax_details)  
        end  
      elsif AppConfiguration.get_config_value('aply_tax_on_menu_item') == 'enabled'
        if tc.tax_type == "service"
          @price_with_service_tax = 0
          @price_with_service_tax = self.unit_price_without_tax
          _tax_amount = 0
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          #total_tax += _tax_amount.round(2)
          total_tax += _tax_amount
          @price_with_service_tax = self.unit_price_without_tax + _tax_amount
          tax_array.push(tax_details)
        elsif tc.tax_type == "tax_on_service"
          _tax_amount = 0
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          #total_tax += _tax_amount.round(2)
          total_tax += _tax_amount
          tax_array.push(tax_details)  
        elsif tc.tax_type == "tax_on_item_price"
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          total_tax += _tax_amount
          #total_tax += _tax_amount.round(2)
          tax_array.push(tax_details)  
        elsif tc.tax_type == "parcel_charge"
          @price_with_service_tax = 0
          @price_with_service_tax = self.unit_price_without_tax
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          #total_tax += _tax_amount.round(2)
          total_tax += _tax_amount
          @service_tax = total_tax
          @price_with_service_tax = self.unit_price_without_tax + _tax_amount
          tax_array.push(tax_details)   
        else
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax.to_f) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          total_tax += _tax_amount
          #total_tax += _tax_amount.round(2)
          tax_array.push(tax_details)
        end   
      else
        _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
        tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
        total_tax += _tax_amount
        tax_array.push(tax_details)  
      end  
    end
    self.update_column(:tax_amount, total_tax) 
    self.update_column(:tax_details, JSON.generate(tax_array)) 
    self.update_column(:unit_price_with_tax, item_unit_price_with_tax) 
    self.update_column(:subtotal, item_subtotal) 
    update_order_prices
  end

  def tax_for_discount total_tax=0,tax_array=[]
    tem_array = Array.new
    @price_with_service_tax = self.unit_price_without_tax
    @service_array = self.menu_product.tax_group.tax_classes
    @service_array.map { |e| tem_array.push e if e.tax_type == "service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "tax_on_service"}
    @service_arr= tem_array | @service_array
    @service_arr.each do |tc|
      if AppConfiguration.get_config_value('variable_tax') == 'enabled'
        if tc.tax_type == 'variable'
          if (tc.lower_limit..tc.upper_limit).include?(self.unit_price_without_tax)
            _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
            tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
            total_tax += _tax_amount
            tax_array.push(tax_details)
          end
        else
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          total_tax += _tax_amount
          tax_array.push(tax_details)  
        end  
      elsif AppConfiguration.get_config_value('aply_tax_on_menu_item') == 'enabled'
        if tc.tax_type == "service"
          @price_with_service_tax = 0
          @price_with_service_tax = self.unit_price_without_tax
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          #total_tax += _tax_amount.round(2)
          total_tax += _tax_amount
          @service_tax = total_tax
          @price_with_service_tax = self.unit_price_without_tax + _tax_amount
          tax_array.push(tax_details)
        elsif tc.tax_type == "tax_on_service"
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @service_tax.to_f) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          #total_tax += _tax_amount.round(2)
          total_tax += _tax_amount
          tax_array.push(tax_details)  
        elsif tc.tax_type == "tax_on_item_price"
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          total_tax += _tax_amount
          #total_tax += _tax_amount.round(2)
          tax_array.push(tax_details)  
        else
          _tax_amount = tc.percentage? ? ((tc.ammount.to_f * @price_with_service_tax.to_f) / 100) : tc.ammount.to_f
          tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
          total_tax += _tax_amount
          #total_tax += _tax_amount.round(2)
          tax_array.push(tax_details)
        end 
      else
        _tax_amount = tc.percentage? ? ((tc.ammount.to_f * self.unit_price_without_tax) / 100) : tc.ammount.to_f
        tax_details = {:tax_class_id => tc.id, :tax_class_name => tc.name, :tax_type => tc.tax_type, :tax_percentage => tc.ammount, :tax_amount => _tax_amount}
        total_tax += _tax_amount
        tax_array.push(tax_details)  
      end  
    end
    self.update_column(:tax_amount, total_tax) 
    self.update_column(:tax_details, JSON.generate(tax_array)) 
    self.update_column(:unit_price_with_tax, item_unit_price_with_tax) 
    self.update_column(:subtotal, item_subtotal) 
    update_order_prices
  end

  # Update order prices
  def update_order_prices
    Order.update_order_price(self.order_id)
  end

  def update_order_for_is_stock_debited
    Order.update_order_for_is_stock_debited(self.order_id)
  end

  # Update order with stock status
  def update_order_for_stock_status
    self.order.reload_stock_issue_status
  end

  def stock_issued! cost
    if cost.to_f.nan?
      cost = 0
    end  
    update_attributes(:material_cost => cost, :is_stock_debited => 'yes')
  end
  # Cancel order item with cause.
  def cancel _cause, _current_user, _is_refandable = '', _account_no = '', _ifsc_code = ''
    update_attributes(:trash => 1, :cancel_cause => _cause, :is_refandable => _is_refandable, :remarks => "Cancled by #{_current_user.profile.firstname} #{_current_user.profile.lastname} (ID: #{_current_user.id})")
    refund_money _account_no, _ifsc_code
  end

  def stock_issued?
    (self.is_stock_debited == "yes") ? true : false
  end

  def stock_not_issued_yet?
    (self.is_stock_debited == "no") ? true : false
  end

  # Check if an item is present in stock or not.
  # If not then check ingredient stock.
  def item_or_its_ingredients_in_stock? product, store_id, quantity, stock_of_items, product_unique_identity
    if self.menu_item_is_buffet_product == false
      if insufficient_in_stock? product.id, quantity, product_unique_identity
        if should_check_ingredient_stock? and product.product_compositions.present?
          item_ingredients_in_stock? product, store_id, quantity, stock_of_items
        else
          stock_of_items[:insufficient_items].push product.name
        end
      else
        stock_of_items[:items_in_stock].push product.id
      end
    end
    customization_items_in_stock? store_id, stock_of_items
    return stock_of_items
  end

  # Check if an item ingredients are present in stock or not
  # Also check item stack level. If stack level is 2 then we have
  # to check another level of ingredient stock.
  def item_ingredients_in_stock? product, store_id, quantity, stock_of_items
    product.product_compositions.each do |raw|
      raw_locked_quantity = raw.inventory_quantity.to_f * quantity.to_f
      if insufficient_in_stock? raw.raw_product_id, raw_locked_quantity, self.product_unique_identity
        # if product.stack_level == 2 and raw.raw_product.product_compositions.present?
        if raw.raw_product.product_compositions.present?
          item_ingredients_in_stock? raw.raw_product, store_id, raw_locked_quantity, stock_of_items
        else
          stock_of_items[:insufficient_items].push product.name
          stock_of_items[:insufficient_ingredients].push raw.raw_product.name
        end
      end
    end
    return stock_of_items
  end

  # Check if customozation items are in stock.
  # Also check ingredient stock of customization items if
  # menu item is of buffet type.
  def customization_items_in_stock? store_id, stock_of_items
    self.order_detail_combinations.each do |object|
      quantity = object.inventory_compatible_quantity object.customization_product_unit_id,object.customization_ammount,self.quantity, object.combination_qty
      if insufficient_in_stock? object.product_id, quantity, self.product_unique_identity
        if self.menu_item_is_buffet_product == true
          item_ingredients_in_stock? object.product, store_id, quantity, stock_of_items
        else
          stock_of_items[:insufficient_items].push self.product.name
          stock_of_items[:insufficient_customizations].push object.product.name
        end
      end
    end
    return stock_of_items
  end

  # Check if order item meets all conditions so that stock can be issued
  # for it from inventory.
  def item_in_state_to_issue_stock?
    return false unless inventory_enabled?
    return false unless should_check_stock?
    return false unless self.status == valid_state_to_issue_stock
    stock_not_issued_yet?
  end

  # Issue stock for order item
  def issue_stock stock_of_items={:items_in_stock => Array.new, :insufficient_items => Array.new, :insufficient_ingredients => Array.new, :insufficient_customizations => Array.new}, cost=0
    unless is_combo_item?
      cost = 0
      item_or_its_ingredients_in_stock? self.product, menu_item_store_id, self.quantity, stock_of_items, self.product_unique_identity
      if stock_of_items[:insufficient_items].present? or stock_of_items[:insufficient_ingredients].present? or stock_of_items[:insufficient_customizations].present?
        raise I18n.t(:error_insufficient_stock, items: stock_of_items[:insufficient_items].uniq.join(', '), ingredients: stock_of_items[:insufficient_ingredients].uniq.join(', '), customizations: stock_of_items[:insufficient_customizations].uniq.join(', ')) if offline_order_disabled?
      else
        if stock_of_items[:items_in_stock].include?(self.product_id)
          if is_uniquely_identifiable_item?
            if is_uniquely_identifiable_item? and self.lot_id.present?
              #lot = Lot.find(self.lot_id)
              #if lot.stock_qty >= self.quantity
              #cost = Stock.reduce_lot_product_stock(self.menu_item_store_id,self.product_id,self.product_unique_identity,self.quantity,self.id,"order_detail",self.lot.stock_id)
              cost = Stock.reduce_product_stock(self.menu_item_store_id,self.product_id,self.quantity,self.id,"order_detail",self.product_unique_identity,'',self.size_name,self.color_name)
              Lot.reduce_lot_stock(self.lot_id,self.quantity)
              if should_check_ingredient_stock? and self.product.product_compositions.present?
                cost = issue_ingredient_stock self.product, self.quantity, cost
              end
              #end 
            else  
              cost = Stock.reduce_sku_product_stock(self.menu_item_store_id,self.product_id,self.product_unique_identity,self.quantity,self.id,"order_detail")
            end
          else
            cost = Stock.reduce_order_product_stock(self.menu_item_store_id,self.product_id,self.quantity,self.id,"order_detail")
            Lot.reduce_stock(self.product_id,self.quantity,self.store_id) if self.menu_product.lots.present?  
          end
        elsif should_check_ingredient_stock? and self.product.product_compositions.present?
          cost = issue_ingredient_stock self.product, self.quantity, cost
        end
        cost = issue_customization_stock cost
        if cost.to_f.nan?
          cost = 0
        end  
        stock_issued! cost
      end
    else
      cost = 0
      item_or_its_ingredients_in_stock? self.product, menu_item_store_id, self.quantity, stock_of_items, self.product_unique_identity
      if stock_of_items[:insufficient_items].present? or stock_of_items[:insufficient_ingredients].present? or stock_of_items[:insufficient_customizations].present?
        raise I18n.t(:error_insufficient_stock, items: stock_of_items[:insufficient_items].uniq.join(', '), ingredients: stock_of_items[:insufficient_ingredients].uniq.join(', '), customizations: stock_of_items[:insufficient_customizations].uniq.join(', ')) if offline_order_disabled?
      else  
        if stock_of_items[:items_in_stock].include?(self.product_id)
          puts "askjkjas askjasjkas askjjkas askjas sakjassaksa-------"
          if is_uniquely_identifiable_item?
            if is_uniquely_identifiable_item? and self.lot_id.present?
              puts "smsdjksd dskjdsjkdsk dskjdskjds sdkjdksjjsdjdsds kjsdkj"
              cost = Stock.reduce_product_stock(self.menu_item_store_id,self.product_id,self.quantity,self.id,"order_detail",self.product_unique_identity,'',self.size_name,self.color_name)
              Lot.reduce_lot_stock(self.lot_id,self.quantity)
              if should_check_ingredient_stock? and self.product.product_compositions.present?
                cost = issue_ingredient_stock self.product, self.quantity, cost
              end
            else  
              cost = Stock.reduce_sku_product_stock(self.menu_item_store_id,self.product_id,self.product_unique_identity,self.quantity,self.id,"order_detail")
            end
          else
            cost = Stock.reduce_order_product_stock(self.menu_item_store_id,self.product_id,self.quantity,self.id,"order_detail")
            Lot.reduce_stock(self.product_id,self.quantity,self.store_id) if self.menu_product.lots.present?  
          end
        elsif should_check_ingredient_stock? and self.product.product_compositions.present?
          cost = issue_ingredient_stock self.product, self.quantity, cost
        end
        cost = issue_customization_stock cost
        if cost.to_f.nan?
          cost = 0
        end  
        stock_issued! cost
      end  

      self.order_details_combos.map { |combo|  cost += Stock.reduce_product_stock(combo.store_id,combo.product_id,combo.quantity,self.id,"order_detail",nil,'','','','',combo.color_id,combo.size_id) }
      if cost.to_f.nan?
        cost = 0
      end 
      cost = 0
      stock_issued! cost
    end
    stock_of_items
  end

  def issue_ingredient_stock product, quantity, cost
    product.product_compositions.each do |raw|
      raw_quantity = raw.inventory_quantity.to_f * quantity.to_f
      if has_sufficient_stock? raw.raw_product_id, raw_quantity
        cost += Stock.reduce_product_stock(self.menu_item_store_id,raw.raw_product_id,raw_quantity,self.id,"order_detail")
        Lot.reduce_stock(raw.raw_product_id,raw_quantity,self.store_id)
      # elsif product.stack_level == 2 and  raw.raw_product.product_compositions.present?
      elsif raw.raw_product.product_compositions.present?
        issue_ingredient_stock raw.raw_product, raw_quantity, cost
      end
    end
    return cost
  end

  def issue_customization_stock total_cost, cost=0
    self.order_detail_combinations.each do |object|
      quantity = object.inventory_compatible_quantity object.customization_product_unit_id,object.customization_ammount,self.quantity, object.combination_qty
      if insufficient_in_stock? object.product_id, quantity, self.product_unique_identity
        cost = issue_ingredient_stock(object.product, quantity, cost) if self.menu_item_is_buffet_product == true
      else
        cost = Stock.reduce_product_stock(self.menu_item_store_id,object.product_id,quantity,self.id,"order_detail")
      end
      object.stock_issued! cost
      total_cost += cost
    end
    return total_cost
  end

  # Check if an item has sufficient stock in inventory or not
  def has_sufficient_stock? product_id, quantity, product_unique_identity=nil
    current_stock = StockUpdate.current_stock(self.menu_item_store_id,product_id) if product_unique_identity.nil?
    current_stock = Stock.available_stock(product_id,self.menu_item_store_id,product_unique_identity) if product_unique_identity.present? and self.lot_id.nil?
    current_stock = Stock.available_lot_stock(product_id,self.menu_item_store_id,product_unique_identity) if product_unique_identity.present? and self.lot_id.present?
    (quantity <= current_stock) ? true : false
  end

  def insufficient_in_stock? product_id, quantity, product_unique_identity
    !has_sufficient_stock? product_id, quantity, product_unique_identity
  end

  def is_combo_item?
    self.product.product_type == "combo"
  end

  def self.by_recorded_at(from_date, upto_date)
    where('order_details.recorded_at BETWEEN ? AND ?',from_date,upto_date)
  end

  def is_uniquely_identifiable_item?
    self.product_unique_identity.nil? ? false : true
  end

  def update_statesss(state)
    update_column(:status, state)
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    # Push notification for new order details *ANDROID*
    _channels = Array.new
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_item_update'
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_item_update'
    Notification.publish_in_faye(_channels,{:order_item => self})
  end

  def has_valid_stock?
    unless valid_item_stock.present?
      errors.add(:base, I18n.t(:error_invalid_sku))
    end
  end

  def has_valid_lot_stock?
    _stock = valid_lot_item_stock
    if _stock.present?
      if self.quantity > _stock.stock_qty
        raise I18n.t(:error_invalid_sku_lot, sku: self.product_unique_identity, lot: self.lot_id, lot_qty: _stock.stock_qty, order_qty: self.quantity)
        #errors.add(:base, I18n.t("Stock Mismatch for lot :#{self.lot_id}, Sku:#{self.product_unique_identity},Product:#{self.product_id}"))
      end
    else
      raise I18n.t(:error_invalid_sku_lot, sku: self.product_unique_identity, lot: self.lot_id)
    end  
  end

  def valid_item_stock
    Stock.available.get_product(self.product_id).by_sku(self.product_unique_identity).set_store(self.menu_item_store_id).first
  end

  def valid_lot_item_stock
    Lot.find(self.lot_id)
  end

  # Return true if inventory module is disabled
  def inventory_enabled?
    AppConfiguration.get_config_value('inventory_module') == 'enabled'
  end

  # Return true if offline ordering is enabled
  def offline_order_enabled?
    AppConfiguration.get_config_value('offline_order') == 'enabled'
  end

  # Return true if offline ordering is enabled
  def offline_order_disabled?
    !offline_order_enabled?
  end

  def valid_state_to_issue_stock
    AppConfiguration.get_config_value('reduce_stock_on_order_status')
  end

  # Return true if stock check while ordering is enabled
  def should_check_stock?
    AppConfiguration.get_config_value('stock_check_on_order') == 'enabled'
  end

  # Return true if stock check of raw items is enabled
  def should_check_ingredient_stock?
    AppConfiguration.get_config_value('check_raw_product_stock') == 'enabled'
  end

  def not_cancled!
    where(["trash =(?)", 0])
  end

  def self.most_sold_items_by_quantity
    OrderDetail.select("sum(quantity) as quantity, product_name").group("product_name").order("quantity DESC")
  end

  def self.most_sold_items_by_price
    OrderDetail.select("sum(subtotal) as total_sale, product_name").group("product_name").order("total_sale DESC")
  end
  # ----------------------------

  def self.check_order_detail_quantity(prev_order_detail,new_order_detail)
    insufficients_products = Array.new

    if new_order_detail['quantity'].to_i > prev_order_detail.quantity.to_i
      puts  "more qty ordered"
      # OrderDetail.check_and_edit_order_detail(prev_order_detail, new_order_detail, insufficients_products)
      menu_product = MenuManagement.get_menu_product_details_by_id(new_order_detail['menu_product_id'])
      more_quantity = new_order_detail['quantity'].to_i - prev_order_detail.quantity.to_i

      # Stock checking for the combination products
      new_order_detail['order_detail_combinations'].each do |order_detail_combination|
        mpc = MenuProductCombination.where("id =? AND menu_product_id =?", order_detail_combination['menu_product_combination_id'], menu_product.id)[0]
        # Here it will fail if the menu product id and combination id does not matched
        required =  mpc.product_unit.id
        prev_order_detail_combination = OrderDetailCombination.where("menu_product_combination_id =(?) AND order_detail_id =(?)", mpc.id, prev_order_detail.id)[0]
        # checking for more or less ordered
        if order_detail_combination['combination_qty'].to_f > prev_order_detail_combination[:combination_qty].to_f
          puts "more"
          more_comb_quantity = order_detail_combination['combination_qty'].to_f - prev_order_detail_combination[:combination_qty].to_f
          current_stock = StockUpdate.current_stock(menu_product[:store_id],mpc.product_id)
          changed_ammount = OrderManagement.change_product_unit(mpc.product.basic_unit,required,mpc.ammount,more_comb_quantity)
          already_ordered_stock = OrderDetail.calculate_already_ordered_stock(menu_product[:store_id], mpc.product_id)
          if current_stock < changed_ammount  + already_ordered_stock
            insufficients_products.push Order.generate_order_error_msg_customise(mpc.product.name,changed_ammount,current_stock)
          else
            puts "its ok"
            prev_order_detail_combination.update_attributes(:combination_qty => order_detail_combination['combination_qty'])
          end

        else
          puts "less"
          prev_order_detail_combination.update_attributes(:combination_qty => order_detail_combination['combination_qty'])
        end
      end

      if menu_product.product.product_type != "combo"
        # puts already_ordered_stock
        current_stock = StockUpdate.current_stock(menu_product[:store_id], menu_product.product.id)
        already_ordered_stock = OrderDetail.calculate_already_ordered_stock(menu_product[:store_id], menu_product.product.id)
        if current_stock < more_quantity + already_ordered_stock
          insufficients_products.push Order.generate_order_error_msg(menu_product.product,more_quantity,current_stock)
        else
          prev_order_detail.update_attributes(:quantity => new_order_detail['quantity'].to_i,:parcel => new_order_detail['parcel'],:preferences => new_order_detail['preferences'])
        end
      else
        if menu_product.combos.present?
          # For combo products we have to check the stock of those menu products who are the combos of this menu product
          menu_product.combos.each do |combo_menu_product|
            current_stock = StockUpdate.current_stock(combo_menu_product[:store_id], combo_menu_product.product[:id])
            # already_ordered_stock = OrderDetail.calculate_already_ordered_stock(menu_product[:store_id], menu_product.product.id)
            already_ordered_stock = OrderDetail.calculate_already_ordered_stock(menu_product[:store_id], combo_menu_product.product[:id])

            if current_stock < more_quantity + already_ordered_stock
              # insufficients_products.push Order.generate_order_error_msg(menu_product,more_quantity,current_stock)
              insufficients_products.push Order.generate_order_error_msg(combo_menu_product.product,more_quantity,current_stock)
            else
              # puts new_order_detail['quantity']
              prev_order_detail.update_attributes(:quantity => new_order_detail['quantity'].to_i,:parcel => new_order_detail['parcel'],:preferences => new_order_detail['preferences'])
            end
          end
        end
      end
    else
      puts "less or equal qty ordered"
      prev_order_detail.update_attributes(:quantity => new_order_detail['quantity'].to_i,:parcel => new_order_detail['parcel'],:preferences => new_order_detail['preferences'])
    end
    return insufficients_products
  end

  #void kot report to csv
  def self.void_kot_report_to_csv(kot_scope)
    CSV.generate do |csv|
      _title = ["Order Id", "Order Item", "Quantity", "Cancel Cause", "Cancel by", "Date" ]
      csv << _title
      kot_scope.each do |object|
        _row = Array.new
        _row.push(object.order_id)
        _row.push(object.product_name)
        _row.push(object.quantity)
        _row.push(object.cancel_cause.humanize) if object.cancel_cause.present?
        _row.push(object.remarks.split(' ')[2..-1].join(' ')) if object.remarks.present?
        _row.push(object.created_at.strftime("%d-%m-%Y, %I:%M %p"))
        csv << _row
      end
    end
  end

  private

  # Code for incentive START
  def update_user_sale
    if AppConfiguration.get_config_value('incentive_commission') == "enabled"
      puts "************"
      puts self.id
    end
  end

  def set_user_sale
    if AppConfiguration.get_config_value('incentive_commission') == "enabled"
      month = self.order.recorded_at.strftime("%m/%Y")
      commission_rule_output = CommissionRuleOutput.by_resource_month_product(self.order.deliverable_id, month, self.product_id)
      _owner_commission = commission_rule_output.count>0 ? commission_rule_output.first.owner_commission_amount : 0
      _thirdparty_commission = commission_rule_output.count>0 ? commission_rule_output.first.csm_commission_amount : 0
      if self.order.deliverable_type.downcase == "resource"
        @user_sale = UserSale.by_user_id(self.order.consumer_id).by_product_id(self.product_id).by_resource_id(self.order.deliverable_id).by_recorded_at(self.order.recorded_at)
        if @user_sale.present? && @user_sale.count > 0
          _quantity = @user_sale[0].quantity.to_f + self.quantity.to_f
          _price_with_tax = @user_sale[0].price_with_tax.to_f + (self.quantity.to_f * self.unit_price_with_tax.to_f)
          _price_without_tax = @user_sale[0].price_without_tax.to_f + (self.quantity.to_f * self.unit_price_without_tax.to_f)
          @user_sale[0].update_attributes(:quantity => _quantity, :price_with_tax => _price_with_tax, :price_without_tax => _price_without_tax, :owner_commission => _owner_commission, :thirdparty_commission => _thirdparty_commission)
        else
          _user_sale = UserSale.new
          _user_sale["user_id"] = self.order.consumer_id
          _user_sale["product_id"] = self.product_id
          _user_sale["resource_id"] = self.order.deliverable_id
          _user_sale["quantity"] = self.quantity
          _user_sale["price_with_tax"] = self.quantity * self.unit_price_with_tax
          _user_sale["price_without_tax"] = self.quantity * self.unit_price_without_tax
          _user_sale["recorded_at"] = self.order.recorded_at
          _user_sale["owner_commission"] = _owner_commission
          _user_sale["thirdparty_commission"] = _thirdparty_commission
          _user_sale.save
        end
      end
    end
  end

  def set_store_id_to_order
    self.order.update_column(:store_id, self.store_id)
  end
  # Code for incentive END

  # Explicitly for Orders V2 API
  def set_attributes
    update_attribute(:unit_id, self.order_unit_id)
    self.order.update_column(:operation_type,self.menu_product.menu_card.operation_type)
  end

  def change_order_status_on_order_details_status
    order = self.order
    case status.downcase
      when "preparing"
        order.update_attributes(:order_status_id => OrderStatus.find_by_name("preparing").id)
      when "prepared"
        if order.order_details.all? { |x| x.status.downcase == "prepared" }
          order.update_attributes(:order_status_id => OrderStatus.find_by_name('prepared').id)
        end
      else
        # puts "No options."
        return
    end
  end

  # =>  Update order detail combinations status on order details status update
  def update_order_detail_combinations_status
    self.order_detail_combinations.update_all(:status => self.status) if self.order_detail_combinations.present?
  end

  # => Update order table for trashed/cancled items
  def update_order_for_cancled_item
    # Update order table price attributes
    Order.update_order_price(self.order_id) if self.trash == 1
    self.order.update_order_trash if self.trash == 1
  end

  # => Update order table for return items
  def update_order_for_return_item
    # Update order table price attributes
    #Order.update_order_price_for_return(self.order_id) if self.is_returned
    #self.order.update_order_trash if self.trash == 1
  end

  def update_bill
    order = self.order
    if order.bills.present?
      _bill = order.bills.first
      if _bill.status != 'void'
        Bill.update_bill_amounts(_bill)
        Bill.calculate_bill_taxes(_bill)
      end  
    end
  end

  def update_bill_for_return_item
    # order = self.order
    # if order.bills.present?
    #   _bill = order.bills.first
    #   Bill.calculate_bill_taxes(_bill)
    #   Bill.update_bill_amounts(_bill)
    # end
  end

  def apply_no_charge
    if self.bill_status == "no_charge"
      self.subtotal = 0
      self.unit_price_without_tax = 0
      self.tax_amount = 0
      #self.tax_details = nil
      self.unit_price_with_tax = 0
    end
  end

  def apply_item_discount
    if self.item_status == "item_discount"
      if self.discount != 0 && self.discount_percentage == 0 
        # if self.discount_percentage == 0
        #   self.discount_percentage = (self.discount / (self.quantity * self.unit_price_without_tax))*100
        # else
        #   self.discount_percentage = (self.discount / (self.discount + (self.quantity * self.unit_price_without_tax)))*100
        # end  
        # self.unit_price_without_tax = self.unit_price_without_tax + self.discount 
        self.discount_percentage = (self.discount * 100) / (self.discount + self.unit_price_without_tax)
        # self.discount_percentage = (self.discount / (self.quantity * self.unit_price_without_tax))*100  #ABDUL COMMANT
        #_discount_tax_amount = ((self.tax_amount * self.discount_percentage) / 100)
        #self.tax_amount = self.tax_amount - _discount_tax_amount
        #_subtotal = self.subtotal - self.discount
        #self.subtotal = _subtotal
        # self.unit_price_without_tax = self.unit_price_without_tax - (self.unit_price_without_tax * self.discount_percentage)/100 #ABDUL COMMANT
        tax_for_discount
      end  
    end   
  end

  # Update order table pricing if bill status changed to no_charge
  def update_order_for_no_charge
    Order.update_order_price(self.order_id) if self.bill_status == "no_charge" #Update order table price attributes
  end

  def push_update_to_subscribers
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    # Push notification for new order details *ANDROID*
    _channels = Array.new
    _channels.push '/notifications/portal/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_item_update'
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_item_update'
    Notification.publish_in_faye(_channels,{:order_item => self})
  end

  def push_update_to_subscribers_for_cancle_item
    if self.trash == 1
      _order_arr = {}
      _order_arr[:order_id] = self.order.id
      _order_arr[:trash] = self.order.trash
      _order_arr[:deliverable_type] = self.order.deliverable_type
      _order_details_array = Array.new
      _arr={}
      _arr[:sort_id] = self.sort_id
      _arr[:order_details_id] = self.id
      _arr[:trash] = self.trash
      _order_details_array.push(_arr)
      _order_arr['order_details'] = _order_details_array
      _subdomain = AppConfiguration.find_by_config_key('site_id')
      # Push notification for new order details *ANDROID*
      _channels = Array.new
      _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+self.unit_id.to_s+'/order_item_cancle'
      Notification.publish_in_faye(_channels,{:order => _order_arr})
    end  
  end

  def refund_money _account_no = '', _ifsc_code = ''
    if self.is_refandable.present? && self.is_refandable == 'yes' && self.trash == 1
      cr_order_array, oreder_array = Array.new, Array.new
      self.order.order_details.map { |e|
        oreder_array.push e
        cr_order_array.push e if e.trash==1
        }
      if cr_order_array.count == oreder_array.count
        if self.order.unit.cancelation_policy.is_delivery_charge_refandable
          amount = self.subtotal + self.order.delivery_charges 
        else
          amount = self.subtotal
        end  
      else
        amount = self.subtotal
      end  
      # if self.order.bill.settlement.present?
      #   self.order.bill.settlement.payments.each do |payment|
      #     if payment['paymentmode_type'] == "PaytmPayment"
      #       #ApplicationController.helpers.refund_to_paytm(payment,amount)
      #     elsif payment['paymentmode_type'] == "Cash"
      #       #RefundManagement::refund_to_customer_wallet(payment)   
      #     elsif payment['paymentmode_type'] == "Card"
      #       #RefundManagement::refund_to_bank(payment)   
      #     else
      #       puts "output"     
      #     end
      #   end
      # end
      cancelation_charge = 0
      _cancelation_policy = self.order.unit.cancelation_policy
      if _cancelation_policy.present?
        if _cancelation_policy.cancelation_charge_type.present? && _cancelation_policy.cancelation_charge.present?
          cancelation_charge = _cancelation_policy.cancelation_charge_type == 'percentage' ? (amount * _cancelation_policy.cancelation_charge.to_f)/100 : _cancelation_policy.cancelation_charge.to_f
        end
      end
      amount = amount - cancelation_charge
      MoneyRefund.create(:customer_id => self.order.customer_id, :order_id => self.order_id, :refund_amount => amount, :account_no => _account_no, :ifsc_code => _ifsc_code)

    end
  end
  
end
