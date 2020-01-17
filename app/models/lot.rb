class Lot < ActiveRecord::Base
  acts_as_copy_target
  attr_accessible :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :sku, :stock_qty, :tax_group_id, :product_id, :expiry_date, :stock_id, :procured_price, :mrp, :menu_card_id, :color_name, :size_name, :model, :color_id, :size_id, :lot_desc, :product_basic_unit, :store_id, :unit_product_id
  
  #Model Validation
  validates :expiry_date, :presence => true

  #Model Association
  belongs_to :product
  belongs_to :tax_group
  belongs_to :unit_product
  belongs_to :store
  has_many :order_details
  has_many :lot_sale_rules
  has_many :sale_rules, :through => :lot_sale_rules

  after_create :assign_tax_group
  after_update :push_update_to_lot
  # after_update :calculate_sell_prices # , if: :tax_group_id_changed?
  scope :active_mode, lambda { where(["mode=?",0])}
  scope :active, lambda { where(["stock_qty > ?",0]) }
  scope :not_expiry, lambda { where(["expiry_date > ?", Date.today]) }
  scope :by_menu_card, lambda {|mc| where(["menu_card_id=?", mc])}
  scope :by_product, lambda {|product| where(["product_id=?", product])}
  scope :by_store, lambda {|store_id|where(["store_id=?", store_id])}
  scope :filter_by_sku, lambda {|sku|where(["lots.sku LIKE (?)","%#{sku}%"])}
  scope :set_store_id_in, lambda {|store_ids|where(["store_id in (?)", store_ids])}

  def assign_tax_group
    update_column(:tax_group_id, self.unit_product.input_tax_group_id) unless self.tax_group_id.present?
    update_column(:product_basic_unit, self.product.basic_unit)
    update_attribute(:sell_price, compute_sell_price)
    update_attribute(:sell_price_without_tax, compute_sell_price_without_tax)
  end
  def calculate_sell_prices
    puts "tax group id changes"
    update_attribute(:sell_price, compute_sell_price)
    update_attribute(:sell_price_without_tax, compute_sell_price_without_tax)
  end
  def update_tax_group
    update_column(:tax_group_id, self.unit_product.input_tax_group_id)
    update_column(:product_basic_unit, self.product.basic_unit)
    update_attribute(:sell_price, compute_sell_price)
  end

  def compute_sell_price
    if AppConfiguration.get_config_value('variable_tax') == 'enabled'
      _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
      @total_amnt = 0
      self.tax_group.tax_classes.each do |tc|
        if tc.tax_type == 'variable'
          if (tc.lower_limit..tc.upper_limit).include?(self.sell_price_without_tax)
            if self.sell_price <= _limit_vtax
              @total_amnt = @total_amnt + 2.5
            else
              if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                @total_amnt = @total_amnt + 9
              else
                @total_amnt = @total_amnt + 6  
              end  
            end 
          end 
        else
          @total_amnt = @total_amnt + tc[:ammount].to_f  
        end
      end
      (self.sell_price_without_tax.to_f + (self.sell_price_without_tax.to_f * @total_amnt.to_f / 100)).round
    else  
      (self.sell_price_without_tax.to_f + (self.sell_price_without_tax.to_f * self.tax_group.total_amnt.to_f / 100)).round
    end
  end

  def compute_sell_price_without_tax
    if AppConfiguration.get_config_value('variable_tax') == 'enabled'
      _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
      @total_amnt = 0
      self.tax_group.tax_classes.each do |tc|
        if tc.tax_type == 'variable'
          if (tc.lower_limit..tc.upper_limit).include?(self.sell_price_without_tax)
            if self.sell_price <= _limit_vtax
              @total_amnt = @total_amnt + 2.5
            else
              if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                @total_amnt = @total_amnt + 9
              else
                @total_amnt = @total_amnt + 6  
              end  
            end 
          end 
        else
          @total_amnt = @total_amnt + tc[:ammount].to_f  
        end
      end
      (self.sell_price.to_f * 100)/(@total_amnt.to_f + 100)
    else  
      (self.sell_price.to_f * 100)/(self.tax_group.total_amnt.to_f + 100)
    end
  end

  def self.product_debit_options(product_id, sku)
    _lots = Lot.where("product_id=? and stock_qty >? and sku=?",product_id,0,sku).order("created_at asc")
    return _lots
  end

  def self.reduce_lot_stock(id,quantity)
    lot = Lot.find(id)
    if lot.present?
      lot.update_attribute(:stock_qty, lot.stock_qty - quantity) if lot.stock_qty >= quantity
    end  
    return quantity
  end

  def self.reduse_sku_product_stock(sku,_consumed_quantity,product_id)
    available_stocks = Lot.product_debit_options(product_id,sku)
    available_stocks.each do |as|
      if as.stock_qty > _consumed_quantity && _consumed_quantity != 0
        _debit_qty = Lot.reduce_lot_stock(as.id,_consumed_quantity)
        _consumed_quantity = 0
      elsif _consumed_quantity > 0
        _debit_qty = Lot.reduce_lot_stock(as.id,as.stock_qty)
        _consumed_quantity = _consumed_quantity - _debit_qty
      end      
    end  
  end

  def self.reduce_stock(product_id,_consumed_quantity,store_id)
    available_stocks = Lot.where("product_id=? and stock_qty >? and store_id=?",product_id,0,store_id).order("created_at asc")
    if available_stocks.present?
      available_stocks.each do |as|
        if as.stock_qty > _consumed_quantity && _consumed_quantity != 0
          _debit_qty = Lot.reduce_lot_stock(as.id,_consumed_quantity)
          _consumed_quantity = 0
        elsif _consumed_quantity > 0
          _debit_qty = Lot.reduce_lot_stock(as.id,as.stock_qty)
          _consumed_quantity = _consumed_quantity - _debit_qty
        end      
      end 
    end   
  end

  # def self.reduce_stock_by_product(product_id,_consumed_quantity)
  #   available_stocks = Lot.find(:all, :conditions => ["product_id=? and stock_qty >?",product_id,0],:order => "created_at")
  #   if available_stocks.present?
  #     available_stocks.each do |as|
  #       if as.stock_qty > _consumed_quantity && _consumed_quantity != 0
  #         _debit_qty = Lot.reduce_lot_stock(as.id,_consumed_quantity)
  #         _consumed_quantity = 0
  #       elsif _consumed_quantity > 0
  #         _debit_qty = Lot.reduce_lot_stock(as.id,as.stock_qty)
  #         _consumed_quantity = _consumed_quantity - _debit_qty
  #       end      
  #     end 
  #   end   
  # end

  def self.save_lot(menu_product_id,mode,sell_price_without_tax,sku,stock_qty,product_id,expiry_date,stock_id,procured_price,mrp,menu_card_id,color_name='',size_name='',size_id=nil,color_id=nil,lot_desc,batch_no,price,store_id,unit_product_id)
    lot = Lot.new
    lot.menu_product_id = menu_product_id
    lot.mode = mode
    lot.sell_price_without_tax = sell_price_without_tax
    lot.sku = sku
    lot.stock_qty = stock_qty
    lot.product_id = product_id
    lot.expiry_date = expiry_date
    lot.stock_id = stock_id
    lot.procured_price = procured_price
    lot.mrp = mrp
    lot.menu_card_id = menu_card_id
    lot.color_name = color_name
    lot.size_name = size_name
    lot.size_id = size_id
    lot.color_id = color_id
    lot.lot_desc = lot_desc
    lot.batch_no = batch_no
    lot.sell_price = price
    lot.store_id = store_id
    lot.unit_product_id = unit_product_id
    lot.save
  end

  private

  #Push method for new lot creation
  def push_update_to_lot
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels=Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/lot/'+self.store.unit_id.to_s+'/lot_update'
    _hash = {:type => 'menu_lot_update', :json_data => self}
    #_hash = {:status => "ok", :messages => {:simple_message => "1 record(s) found"},:data => [{:id => self.id,:menu_card_id => self.menu_card_id, :menu_product_id => self.menu_product_id, :sell_price => self.sell_price, :sell_price_without_tax => self.sell_price_without_tax, :sku => self.sku,:stock_qty => self.stock_qty, :tax_group_id => self.tax_group_id, :product_id => self.product_id,:expiry_date => self.expiry_date, :stock_id => self.stock_id,:procured_price => self.procured_price, :mrp => self.mrp, :basic_unit => self.product.basic_unit }]}
    Notification.publish_in_faye(_channels,_hash)
  end  
end