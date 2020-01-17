class OrderDetailsCombo < ActiveRecord::Base
  attr_accessible :color_id, :combo_item_id, :is_stock_debited, :lot_id, :order_detail_id, :product_id, :product_name, :product_unique_identity, :quantity, :size_id, :subtotal, :tax_amount, :tax_details, :unit_price_with_tax, :unit_price_without_tax, :store_id
  #Model Association
  belongs_to :order_detail
  belongs_to :product
  belongs_to :lot
  belongs_to :combo_item
  belongs_to :store
  belongs_to :color
  belongs_to :size
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('color_id')
        self.color_id = self.combo_item.color_id
      end
      if !initialized.key?('is_stock_debited')
        self.is_stock_debited = 'No'
      end
      if !initialized.key?('product_id')
        self.product_id = self.combo_item.item_id
      end
      if !initialized.key?('product_name')
        self.product_name = self.combo_item.product.name
      end
      if !initialized.key?('size_id')
        self.size_id = self.combo_item.size_id
      end
      if !initialized.key?('store_id')
        self.store_id = self.combo_item.menu_product.store_id
      end
    end
  end

  #Model Callback
  before_save :set_dynamic_item_attributes

  # Setting item pricing attributes for both catalog and non-catalog items
  def set_dynamic_item_attributes
    # lot = Lot.find_by_product_id_and_store_id_and_color_id_and_size_id(self.product_id,self.store_id,self.color_id,self.size_id)
    # self.lot_id = lot.id
    self.quantity = self.combo_item.quantity * self.order_detail.quantity
    self.unit_price_without_tax = self.combo_item.sell_price_without_tax
    set_item_taxes
    self.unit_price_with_tax = item_unit_price_with_tax
    self.subtotal = item_subtotal
  end  
  
  def set_item_taxes total_tax=0,tax_array=[]
    tem_array = Array.new
    @price_with_service_tax = self.unit_price_without_tax
    @service_array = self.combo_item.tax_group.tax_classes
    @service_array.sort { |a, b|  a.ammount <=> b.ammount }
    @service_array.map { |e| tem_array.push e if e.tax_type == "service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "tax_on_service"}
    @service_array.map { |e| tem_array.push e if e.tax_type == "parcel_charge"}
    @service_arr= tem_array | @service_array
    if self.order_detail.menu_product.menu_card.operation_type == "b2b"
      if self.order_detail.order.customer.present?
        business_gstin = self.order_detail.order.unit.unit_detail.options[:gst_code]
        customer_gstin = self.order_detail.order.customer.gstin
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
                  tax_classs = TaxClass.by_tax_type('variable').by_ammount(6)
                  tax_class = tax_classs[0]
                  _tax_amount = tax_class.percentage? ? ((tax_class.ammount.to_f * self.unit_price_without_tax) / 100) : tax_class.ammount.to_f
                  tax_details = {:tax_class_id => tax_class.id, :tax_class_name => tax_class.name, :tax_type => tax_class.tax_type, :tax_percentage => tax_class.ammount, :tax_amount => _tax_amount}
                  total_tax += _tax_amount
                  tax_array.push(tax_details)
                elsif i == 4
                  tax_classs = TaxClass.by_tax_type('variable').by_ammount(6)
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
    
    self.tax_amount = total_tax
    self.tax_details = JSON.generate(tax_array)
  end

  def item_unit_price_with_tax
    self.unit_price_without_tax + self.tax_amount
  end

  # Calculate item subtotal
  def item_subtotal  
    (self.unit_price_with_tax * self.quantity)
  end

end
