class Stock < ActiveRecord::Base
  attr_accessible :available_stock, :consumption_log, :price, :product_id, :stock_credit, :stock_debit, :stock_transaction_id, :stock_transaction_type, :store_id, :expiry_date, :sku, :mfg_date, :color_name, :model_number, :size_name, :sell_price_with_tax, :color_id, :size_id, :batch_no, :is_barcode_printed, :stock_identity, :mrp, :landing_price, :p_gender

  belongs_to :stock_transaction, polymorphic: true
  belongs_to :store
  belongs_to :product
  belongs_to :color
  belongs_to :size
  has_one :stock_update, :class_name => "StockUpdate", :foreign_key => "stock_ref_id"
  has_one :stock_defination  
  has_one :stock_price
  has_many :stock_taxes, :class_name => "StockTax", :foreign_key => "stock_id"
  has_many :secondary_stocks
  has_one :lot
  has_many :notifications, as: :notification_source

  # => Model Callbacks
  after_create :update_stock_counter, :check_safety_stock_level, :generate_sku, :check_expiry_date, :update_stock_identity, :update_batch_no
  # => Model Validations
  validates :product_id,      :presence => true
  validates :store_id,        :presence => true
  validates :stock_transaction_id,  :presence => true
  validates :stock_transaction_type,:presence => true
  
  # => Model scopes

  scope :get_product,             lambda {|product_id|where(["product_id=?", product_id])}
  scope :has_sell_price_with_tax,  lambda{ where(["sell_price_with_tax>?",0])}
  scope :get_product_in,          lambda {|product_ids|where(["product_id in (?)", product_ids])}
  scope :get_product_not_in,      lambda {|product_ids|where(["product_id not in (?)", product_ids])}
  scope :set_store,               lambda {|store_id|where(["store_id=?", store_id])}
  scope :set_store_in,            lambda {|store_ids|where(["store_id in (?)", store_ids])}
  scope :set_transaction,         lambda {|t_id|where(["stock_transaction_id=?", t_id])}
  scope :set_transaction_in,      lambda {|t_ids|where(["stock_transaction_id in (?)", t_ids])}
  scope :set_transaction_type,    lambda {|t_type|where(["stock_transaction_type=?", t_type])}
  scope :set_transaction_type_in, lambda {|t_types|where(["stock_transaction_type in(?)", t_types])}
  scope :desc_order,              lambda { order("created_at desc") }
  scope :type_credit,             lambda { where(["stock_credit > ? and stock_debit = ?",0,0]) }
  scope :type_debit,              lambda { where(["stock_credit = ? and stock_debit > ?",0,0]) }
  scope :last_day,                lambda { where(["created_at > ?",Time.zone.now.beginning_of_day]) }
  scope :last_week,               lambda { where(["created_at > ?",7.day.ago]) }
  scope :last_month,              lambda { where(["created_at > ?",30.day.ago]) }
  scope :last_quarter,            lambda { where(["created_at > ?",90.day.ago]) }
  scope :available,               lambda { where(["available_stock > ?",0]) }
  scope :by_sku,                  lambda {|sku|where(["cast(sku as text) = ?", "#{sku}"])}
  scope :by_product_sku,          lambda {|sku|where (["sku=?",sku])}
  scope :by_store,                lambda {|store_id|where(["store_id=?", store_id])}
  scope :by_product,              lambda {|product_id|where(["product_id=?", product_id])}
  scope :by_products,             lambda {|product_ids|where(["product_id in (?)", product_ids])}
  scope :ordered, ->              { includes(:product).order("product.name ASC")}
  scope :by_date_range,           lambda {|from_date, upto_date|where('stocks.created_at BETWEEN ? AND ?',from_date,upto_date)}
  scope :by_category_id,          lambda{|category_id| joins(:product).merge(Product.by_category_id(category_id))}
  scope :by_product_name,         lambda{|product_name| joins(:product).merge(Product.by_product_name(product_name))}
  scope :check_date,              lambda{|date|where(["date(stocks.created_at)<=?", date])}
  scope :get_expiry_date_in,      lambda {|expiry_dates|where(["expiry_date in (?)", expiry_dates])}
  scope :by_expiry_date_range,    lambda {|from_date, upto_date|where('stocks.expiry_date BETWEEN ? AND ?',from_date,upto_date)}
  scope :by_business_type,        lambda{|business_type| joins(:product).merge(Product.by_business_type(business_type))}
  scope :get_color,               lambda {|color_id|where(["color_id=?", color_id])}
  scope :get_size,                lambda {|size_id|where(["size_id=?", size_id])}
  scope :by_model_number,         lambda {|model_number|where(["model_number=?", model_number])}
  scope :by_batch_no,             lambda {|batch_no|where(["batch_no=?", batch_no])}
  scope :by_sell_price,           lambda {|sell_price|where(["sell_price_with_tax=?", sell_price])}
  scope :by_model_no,             lambda {|model_number|where(["model_number=?", model_number])}
  scope :by_sell_price_with_tax,  lambda {|sell_price|where(["sell_price_with_tax=?", sell_price])}
  scope :by_batch,                lambda {|batch_no|where(["batch_no=?", batch_no])}
  scope :set_expiry_date,         lambda {|expiry_date|where(["expiry_date=?", expiry_date])}

  delegate :sell_price, :weight,:making_cost,:wastage,:description, allow_nil: true, :to => :stock_defination
  delegate :description, :received_product_unit, :weight, :product_unit, :to => :stock_defination, allow_nil: true, prefix: false
  delegate :name, :sell_type, :to => :product, prefix: true

  def self.available_stock(product_id,store_id,sku,id=nil)
    if id != nil
      _stock = Stock.find(id)
    else  
      _stock = get_product(product_id).set_store(store_id).by_sku(sku).available.first
    end
    return _stock.present? ? _stock.available_stock : 0
  end

  def self.product_variation_available_stock(product_id,store_id,sku=nil,color_id=nil,size_id=nil,batch_no=nil,expiry_date=nil,model_number=nil,sell_price_with_tax=nil)
    _product_stock = Stock.get_product(product_id).set_store(store_id)
    _product_stock = _product_stock.by_sku(sku) if sku != nil and sku != ''
    _product_stock = _product_stock.get_color(color_id) if color_id != nil and color_id != ''
    _product_stock = _product_stock.get_size(size_id) if size_id != nil and size_id != ''
    _product_stock = _product_stock.by_batch(batch_no) if batch_no != nil and batch_no != ''
    _product_stock = _product_stock.set_expiry_date(expiry_date) if expiry_date != nil and expiry_date != ''
    # _product_stock = _product_stock.by_sell_price_with_tax(sell_price_with_tax) if sell_price_with_tax != nil and sell_price_with_tax != ''
    _product_stock = _product_stock.by_model_no(model_number) if model_number != nil and model_number != ''
    puts "product stocks : "
    p _product_stock
    _product_stock = _product_stock.available.sum(:available_stock)
      
    return _product_stock

  end

  def self.available_lot_stock(_product_id,_store_id,sku)
    _product_stock = Stock.get_product(_product_id).set_store(_store_id).by_sku(sku).available.sum(:available_stock)
    return _product_stock
  end

  def self.available_sku_stock(_store_id,sku)
    _product_stock = Stock.set_store(_store_id).by_sku(sku).available
    return _product_stock
  end

  def self.by_expiry_date product_id, store_id
    stocks = Stock.select("id,sku,expiry_date,sum(available_stock) as total_stock").group("id,date(expiry_date), sku").set_store(store_id).get_product(product_id).available.order("date(expiry_date) asc")
  end
  # => Generic function to save a stock
  def self.save_stock(product_id,store_id,price,available_stock,stock_transaction_id,stock_transaction_type,stock_credit,stock_debit,expiry_date,sku,mfg_date,model_number='',size='',color_name='',sell_price_with_tax='',color_id='',size_id='',batch_no='',free_quantity='',stock_identity='',p_gender='')
    _transaction                        = stock_transaction_type.capitalize.classify.constantize.find(stock_transaction_id)
    _new_stock                          = _transaction.stocks.new  
    _new_stock[:product_id]             = product_id
    _new_stock[:store_id]               = store_id
    _new_stock[:price]                  = price.to_f.round(2)
    _new_stock[:available_stock]        = available_stock
    _new_stock[:stock_credit]           = stock_credit
    _new_stock[:stock_debit]            = stock_debit
    _new_stock[:expiry_date]            = expiry_date
    _new_stock[:sku]                    = sku
    _new_stock[:mfg_date]               = mfg_date
    _new_stock[:model_number]           = model_number
    _new_stock[:size_name]              = size
    _new_stock[:color_name]             = color_name
    _new_stock[:sell_price_with_tax] = sell_price_with_tax
    _new_stock[:color_id]               = color_id
    _new_stock[:size_id]                = size_id
    _new_stock[:batch_no]               = batch_no
    _new_stock[:free_quantity]          = free_quantity
    _new_stock[:stock_identity]         = stock_identity
    _new_stock[:p_gender]               = p_gender
    _new_stock.save
    return _new_stock
  end  

  # def received_product_unit
  #   self.stock_defination.received_product_unit
  # end

  def self.credit product_id,store_id,price,quantity,stock_transaction_type,stock_transaction_id,sku,model_number='',size='',color_name='',sell_price_with_tax='',color_id='',size_id='',batch_no='',stock_identity=''
    _transaction = stock_transaction_type.camelize.classify.constantize.find(stock_transaction_id)
    #_stock = _transaction.stocks.new(:product_id => product_id, :store_id => store_id, :price => price, :available_stock => quantity, :stock_credit => quantity, :stock_debit => 0, :sku => sku, :model_number => model_number, :color_name => color_name, :sell_price_with_tax => sell_price_with_tax )
    _stock = _transaction.stocks.new
    _stock[:product_id]= product_id
    _stock[:store_id]= store_id
    _stock[:price]= price
    _stock[:available_stock]= quantity
    _stock[:stock_credit]= quantity
    _stock[:stock_debit]= 0
    _stock[:sku]= sku
    _stock[:model_number]= model_number
    _stock[:size_name]= size
    _stock[:color_name]= color_name
    _stock[:sell_price_with_tax]= sell_price_with_tax
    _stock[:color_id]=color_id
    _stock[:size_id]=size_id
    _stock[:batch_no]=batch_no
    _stock[:stock_identity] = stock_identity
    _stock.save!
    return _stock
  end

  # =>  getting all possible transfer options
  def self.product_debit_options(store_id, product_id, sku='',size_id='',color_id='',stock_transaction_id='',stock_transaction_type='')
    if stock_transaction_id != '' and stock_transaction_type == 'stock_purchase'
      _stocks = Stock.where("product_id=? and store_id =? and available_stock >? and stock_transaction_id=? and stock_transaction_type=?",product_id,store_id,0,stock_transaction_id,'StockPurchase').order("created_at asc")
    else
      if sku == ''
        if (size_id != '' and size_id != nil) and (color_id != '' and color_id != nil)
          _stocks = Stock.where("product_id=? and store_id =? and available_stock >? and size_id=? and color_id=?",product_id,store_id,0,size_id,color_id).order("created_at asc")
        elsif size_id != '' and size_id != nil
          _stocks = Stock.where("product_id=? and store_id =? and available_stock >? and size_id=?",product_id,store_id,0,size_id).order("created_at asc")
        elsif color_id != '' and color_id != nil
          _stocks = Stock.where("product_id=? and store_id =? and available_stock >? and color_id=?",product_id,store_id,0,color_id).order("created_at asc")
        else  
          _stocks = Stock.where("product_id=? and store_id =? and available_stock >?",product_id,store_id,0).order("created_at asc")
        end
      else
        _stocks = Stock.where("product_id=? and store_id =? and available_stock >? and sku=?",product_id,store_id,0,sku).order("created_at asc")
      end
    end
    return _stocks
  end

  # =>  get stock price
  def self.get_stock_price(stock_id,product_qty)
    _stock = Stock.find(stock_id)
    _qty_price = (_stock.price.to_f / _stock.stock_credit.to_f) * product_qty
    return _qty_price
  end
  
  def sell_price_of_item _quantity=nil, _cost_of_stock=0, _final_price=0
    if self.product.by_weight?
      _sub_product = self.product.product_compositions.first.raw_product
      _item_weight = (self.stock_defination.product_unit.multiplier.to_f)*(self.weight.to_f) #Generating the stock to consume
      _wastage_price = ((_item_weight * (self.wastage.to_f) / 100) * _sub_product.price.to_f)
      _cost_of_stock = ((_sub_product.price.to_f * _item_weight) + self.making_cost.to_f + _wastage_price.to_f)
      _final_price = _quantity.nil? ? _cost_of_stock : (_cost_of_stock * _quantity.to_f / self.stock_credit.to_f) 
    elsif self.product.by_mrp?
      _final_price = self.sell_price
    elsif self.product.by_bulk_weight?
      _sub_product = self.product.product_compositions.first
      _item_weight = (self.stock_defination.product_unit.multiplier.to_f * self.weight.to_f) #Generating the stock to consume
      _cost_of_stock = ((_sub_product.raw_product.price.to_f * _item_weight) + self.making_cost.to_f + self.wastage.to_f)
      _final_price = _quantity.nil? ? _cost_of_stock : (_sub_product.product_unit.multiplier.to_f * _quantity.to_f * _cost_of_stock / _item_weight) 
    else
      _final_price = _quantity.nil? ? self.price : (self.price * _quantity.to_f / self.stock_credit)
    end
    return _final_price.present? ? _final_price.round(2) : 0
  end


  # => Consume product in log and update available stock
  def self.consume_stock_debit(stock_id,product_qty,_new_stock_id,_reason,stock_transaction_id=nil)
    _stock = Stock.find(stock_id)
    if _stock.available_stock.to_f > product_qty.to_f
      @new_qty = _stock.available_stock - product_qty
    else
      @new_qty = 0
      product_qty = _stock.available_stock
    end
    _current_time = Time.now.strftime("%d-%m-%Y %H:%M")
    if _stock.consumption_log
      _con_log = JSON.parse(_stock.consumption_log)
    else
      _con_log = Array.new
    end
    _arr = {}
    _arr[:stock_id] = _new_stock_id
    _arr[:consumed_quantity] = product_qty
    _arr[:stock_transaction_id] = stock_transaction_id
    _arr[:consumed_for] = _reason
    _arr[:time] = _current_time
    _con_log.push(_arr)
    _con_log_json = JSON.generate(_con_log)
    _stock.update_attribute(:available_stock, @new_qty) #Update new available stock
    _stock.update_attribute(:consumption_log, _con_log_json) #Update new consumption in log
    return product_qty
  end

  def self.consumption_with_automated_debit(_store_id,_product_id,_total_quantity,_consumption_reason)
    _debit_options = Stock.product_debit_options(_store_id,_product_id)
    _total_price = 0
    _debit_options.each do |top|
      if _total_quantity.to_f > top.available_stock.to_f
        Stock.consume_stock_debit(top.id,top.available_stock.to_f,nil,_consumption_reason)
        _total_price = _total_price + (Stock.get_stock_price(top.id,top.available_stock.to_f))
        _total_quantity = (_total_quantity.to_f) - (top.available_stock.to_f)
      elsif _total_quantity.to_f > 0
        Stock.consume_stock_debit(top.id,_total_quantity.to_f,nil,_consumption_reason)
        _total_price = _total_price + (Stock.get_stock_price(top.id,_total_quantity))
        _total_quantity = 0
      end
    end
    return _total_price
  end

  def self.reduce_stock(stock_id,stock_transaction_type,stock_transaction_id,debit_stock)
    _stock = Stock.find(stock_id)
    _debit_qty = Stock.consume_stock_debit(_stock.id,debit_stock,nil,"StockAudit")
    _total_cost = _stock.sell_price_of_item debit_stock
    _new_stock_debit = Stock.save_stock(_stock.product_id,_stock.store_id,_total_cost,0,stock_transaction_id,stock_transaction_type,0,debit_stock,_stock.expiry_date,_stock.sku,_stock.mfg_date)
    return _total_cost
  end

  def self.reduce_sku_product_stock(_store_id,_product_id,sku,_consumed_quantity, stock_transaction_id, stock_transaction_type)
    _stock = Stock.get_product(_product_id).set_store(_store_id).by_sku(sku).available.first
    raise "Invalid SKU" unless _stock.present?
    raise "#{_stock.product.name} has insufficient stock to complete this operation. (Current stock: #{_stock.available_stock} #{_stock.product.basic_unit}, Required: #{_consumed_quantity} #{_stock.product.basic_unit})" if _consumed_quantity > _stock.available_stock.to_f 
    _debit_qty = Stock.consume_stock_debit(_stock.id,_consumed_quantity,nil,"Order")
    _total_cost = _stock.sell_price_of_item _consumed_quantity
    _new_stock_debit = Stock.save_stock(_product_id,_store_id,_total_cost,0,stock_transaction_id,stock_transaction_type,0,_debit_qty,nil,sku,nil)
    return _total_cost
  end

  def self.reduce_lot_product_stock(_store_id,_product_id,sku,_consumed_quantity, stock_transaction_id, stock_transaction_type,lot_id)
    _stock = Stock.find(lot_id)
    raise "Invalid SKU" unless _stock.present?
    raise "#{_stock.product.name} has insufficient stock to complete this operation. (Current stock: #{_stock.available_stock} #{_stock.product.basic_unit}, Required: #{_consumed_quantity} #{_stock.product.basic_unit})" if _consumed_quantity > _stock.available_stock.to_f 
    _debit_qty = Stock.consume_stock_debit(_stock.id,_consumed_quantity,nil,"Order")
    _total_cost = _stock.sell_price_of_item _consumed_quantity
    _new_stock_debit = Stock.save_stock(_product_id,_store_id,_total_cost,0,stock_transaction_id,stock_transaction_type,0,_debit_qty,nil,sku,nil)
    return _total_cost
  end

  def self.reduce_product_stock(_store_id,_product_id,_consumed_quantity,stock_transaction_id,stock_transaction_type,sku=nil,model_number='',size='',color_name='',sale_price_without_tax='',color_id='',size_id='',batch_no='')
    if sku == nil
      if size_id != '' or color_id != ''
        available_stocks = Stock.product_debit_options(_store_id, _product_id,'',size_id,color_id)
        _product_stock = Stock.get_product(_product_id).set_store(_store_id)
        _product_stock = _product_stock.get_size(size_id) if size_id != nil
        _product_stock = _product_stock.get_color(color_id) if color_id != nil
        _product_stock = _product_stock.available.sum(:available_stock)
      else
        available_stocks = Stock.product_debit_options(_store_id, _product_id, '', '', '', stock_transaction_id,stock_transaction_type)
        _product_stock = StockUpdate.current_stock(_store_id, _product_id)
      end  
    else
      available_stocks = Stock.product_debit_options(_store_id, _product_id,sku)
      _product_stock = Stock.get_product(_product_id).set_store(_store_id).by_sku(sku).available.sum(:available_stock)
    end  

    _product = Product.find(_product_id)
    raise "#{_product.name} has insufficient stock to complete this operation. (Current stock: #{_product_stock} #{_product.basic_unit}, Required: #{_consumed_quantity} #{_product.basic_unit})" unless _product_stock.to_f >= _consumed_quantity.to_f
    _total_debit, _total_price = 0, 0
    available_stocks.each do |as|
      if as.available_stock > _consumed_quantity && _consumed_quantity != 0
        _debit_qty = Stock.consume_stock_debit(as.id,_consumed_quantity,nil,stock_transaction_type,stock_transaction_id)
        _price = Stock.get_stock_price(as.id,_debit_qty)
        _total_price = _total_price + _price
        _total_debit = _total_debit + _debit_qty
        _consumed_quantity = 0
      elsif _consumed_quantity > 0
        _debit_qty = Stock.consume_stock_debit(as.id,as.available_stock,nil,stock_transaction_type,stock_transaction_id)
        _price = Stock.get_stock_price(as.id,_debit_qty)
        _total_price = _total_price + _price
        _total_debit = _total_debit + _debit_qty  
        _consumed_quantity = _consumed_quantity - _debit_qty     
      end
    end
    _new_stock_debit = Stock.save_stock(_product_id,_store_id,_total_price,0,stock_transaction_id,stock_transaction_type,0,_total_debit,nil,sku,nil,model_number,size,color_name,sale_price_without_tax,color_id,size_id,batch_no) if _total_debit > 0
    return _total_price
  end

  def self.reduce_product_stock_by_stock_id(stock_id,_consumed_quantity,stock_transaction_id,stock_transaction_type,sale_price_without_tax)
    _stock = Stock.find(stock_id)
    _total_debit = Stock.consume_stock_debit(stock_id,_consumed_quantity,nil,"StockTransfer")
    _total_price = Stock.get_stock_price(stock_id,_consumed_quantity)
    _new_stock_debit = Stock.save_stock(_stock.product_id,_stock.store_id,_total_price,0,stock_transaction_id,stock_transaction_type,0,_total_debit,nil,_stock.sku,nil,_stock.model_number,_stock.size,_stock.color_name,sale_price_without_tax,_stock.color_id,_stock.size_id,_stock.batch_no,_stock.stock_identity)
    return _total_price
  end

  def self.reduce_order_product_stock(_store_id,_product_id,_consumed_quantity,stock_transaction_id,stock_transaction_type,sku=nil,model_number='',size='',color_name='',sale_price_without_tax='',color_id='',size_id='',batch_no='')        
    if sku == nil
      available_stocks = Stock.product_debit_options(_store_id, _product_id)
      _product_stock = StockUpdate.current_stock(_store_id, _product_id)
    else
      available_stocks = Stock.product_debit_options(_store_id, _product_id,sku)
      _product_stock = Stock.get_product(_product_id).set_store(_store_id).by_sku(sku).available.sum(:available_stock)
    end  

    _product = Product.find(_product_id)
    raise "#{_product.name} has insufficient stock to complete this operation. (Current stock: #{_product_stock} #{_product.basic_unit}, Required: #{_consumed_quantity} #{_product.basic_unit})" unless _product_stock.to_f >= _consumed_quantity
    _total_debit, _total_price = 0, 0
    
    available_stocks.each do |as|
      if as.available_stock > _consumed_quantity && _consumed_quantity != 0
        _debit_qty = Stock.consume_stock_debit(as.id,_consumed_quantity,nil,"Order")
        Lot.reduse_sku_product_stock(as.sku,_consumed_quantity,_product_id) if as.sku.present?
        _price = Stock.get_stock_price(as.id,_debit_qty)
        _total_price = _total_price + _price
        _total_debit = _total_debit + _debit_qty
        _consumed_quantity = 0
      elsif _consumed_quantity > 0
        _debit_qty = Stock.consume_stock_debit(as.id,as.available_stock,nil,"Order")
        Lot.reduse_sku_product_stock(as.sku,as.available_stock,_product_id) if as.sku.present?
        _price = Stock.get_stock_price(as.id,_debit_qty)
        _total_price = _total_price + _price
        _total_debit = _total_debit + _debit_qty  
        _consumed_quantity = _consumed_quantity - _debit_qty     
      end
    end
    _new_stock_debit = Stock.save_stock(_product_id,_store_id,_total_price,0,stock_transaction_id,stock_transaction_type,0,_total_debit,nil,sku,nil,model_number,size,color_name,sale_price_without_tax,color_id,size_id,batch_no)
    return _total_price
  end

  def self.check_stock_date(from_date, upto_date)
    if from_date.present? && upto_date.present?
      where('stocks.created_at BETWEEN ? AND ?',from_date,upto_date)
    else
      all
    end    
  end  
  def self.get_stock_data(product, store, from_date, to_date)
    total_debit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_debit)
    total_credit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_credit)
    product_stock = StockUpdate.current_stock(store, product)
    _arr = {}
    _arr[:total_credit] = total_credit.present? ? total_credit : 0
    _arr[:total_debit]  = total_debit.present? ? total_debit : 0
    _arr[:current_stock]  = product_stock.present? ? product_stock : 0
    return _arr
  end
  def self.get_stock_report(store, product, from_date, to_date)
    # opening_stock = StockUpdate.by_store(store).by_product(product).where('created_at <(?)',from_date).last
    # audit_stock = (Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).set_transaction_type('StockAudit').first)
    # closing_stock = StockUpdate.by_store(store).by_product(product).where('created_at <=(?)',to_date).last
    # total_debit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_debit)
    # total_credit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_credit)
    # total_purchase = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_credit.set_transaction_type("StockPurchase").sum(:stock_credit)
    # audit_consumption = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockAudit").sum(:stock_debit)
    # order_consumption = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type_in(['Order','OrderDetail']).sum(:stock_debit)
    # transfer_consumption = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockTransfer").sum(:stock_debit)
    # current_stock_price = Stock.select("sum(price * available_stock/stock_credit) as current_price").get_product(product).set_store(store).type_credit.available.first
    # _arr = {}
    # _arr[:opening_stock]        = opening_stock.present? ? opening_stock.stock : 0
    # _arr[:initial_audit_stock]  = audit_stock.present? ? audit_stock.stock_update.stock : _arr[:opening_stock]
    # _arr[:initial_audit_date]   = audit_stock.present? ? audit_stock.created_at.strftime("%d %b %Y, %I:%M %p") : "OS"
    # _arr[:closing_stock]        = closing_stock.present? ? closing_stock.stock : 0
    # _arr[:total_credit]         = total_credit.present? ? total_credit : 0
    # _arr[:total_debit]          = total_debit.present? ? total_debit : 0
    # _arr[:total_purchase]       = total_purchase.present? ? total_purchase : 0
    # _arr[:audit_consumption]    = audit_consumption.present? ? audit_consumption : 0
    # _arr[:order_consumption]    = order_consumption.present? ? order_consumption : 0
    # _arr[:transfer_consumption] = transfer_consumption.present? ? transfer_consumption : 0
    # _arr[:current_stock_price]  = current_stock_price.current_price.present? ? current_stock_price.current_price : 0
    # return _arr
    opening_stock = StockUpdate.by_store(store).by_product(product).where('created_at <(?)',from_date).last
    audit_stock = (Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).set_transaction_type('StockAudit').first)
    closing_stock = StockUpdate.by_store(store).by_product(product).where('created_at <=(?)',to_date).last
    total_debit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_debit)
    total_credit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_credit)
    total_purchase = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_credit.set_transaction_type("StockPurchase").sum(:stock_credit)
    audit_consumption = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockAudit").sum(:stock_debit)
    order_consumption = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type_in(['Order','OrderDetail']).sum(:stock_debit)
    transfer_consumption = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockTransfer").sum(:stock_debit)
    current_stock_price = Stock.select("sum(price * available_stock/stock_credit) as current_price").group(:id).get_product(product).set_store(store).type_credit.available.first
    total_credit_price = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_credit.sum(:price)
    total_debit_price = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.sum(:price)
    total_purchase_price = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_credit.set_transaction_type("StockPurchase").sum(:price)
    audit_consumption_price = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockAudit").sum(:price)
    order_consumption_price = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type_in(['Order','OrderDetail']).sum(:price)
    transfer_consumption_price = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockTransfer").sum(:price)
    credit_on_audit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_credit.set_transaction_type("StockAudit").sum(:stock_credit)
    credit_on_transfer = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).type_credit.set_transaction_type("StockTransfer").sum(:stock_credit)
    _arr = {}
    _arr[:opening_stock]              = opening_stock.present? ? opening_stock.stock : 0
    _arr[:initial_audit_stock]        = audit_stock.present? ? audit_stock.stock_update.stock : _arr[:opening_stock]
    _arr[:initial_audit_date]         = audit_stock.present? ? audit_stock.created_at.strftime("%d %b %Y, %I:%M %p") : "OS"
    _arr[:closing_stock]              = closing_stock.present? ? closing_stock.stock : 0
    _arr[:total_credit]               = total_credit.present? ? total_credit : 0
    _arr[:total_debit]                = total_debit.present? ? total_debit : 0
    _arr[:total_purchase]             = total_purchase.present? ? total_purchase : 0
    _arr[:audit_consumption]          = audit_consumption.present? ? audit_consumption : 0
    _arr[:order_consumption]          = order_consumption.present? ? order_consumption : 0
    _arr[:transfer_consumption]       = transfer_consumption.present? ? transfer_consumption : 0
    _arr[:current_stock_price]        = current_stock_price.present? ? current_stock_price.current_price : 0
    _arr[:total_credit_price]         = total_credit_price.present? ? total_credit_price : 0
    _arr[:total_debit_price]          = total_debit_price.present? ? total_debit_price : 0
    _arr[:total_purchase_price]       = total_purchase_price.present? ? total_purchase_price : 0
    _arr[:audit_consumption_price]    = audit_consumption_price.present? ? audit_consumption_price : 0
    _arr[:order_consumption_price]    = order_consumption_price.present? ? order_consumption_price : 0
    _arr[:transfer_consumption_price] = transfer_consumption_price.present? ? transfer_consumption_price : 0
    _arr[:credit_on_audit]            = credit_on_audit.present? ? credit_on_audit : 0
    _arr[:credit_on_transfer]         = credit_on_transfer.present? ? credit_on_transfer : 0
    return _arr
  end

  def self.get_opening_closing(store,product,from_date,to_date)
    _price = 0
    opening_stock = StockUpdate.by_store(store).by_product(product).where('created_at <(?)',from_date).last
    closing_stock = StockUpdate.by_store(store).by_product(product).where('created_at <=(?)',to_date).last
    current_stock_price = Stock.select("price / stock_credit as unit_price").get_product(product).set_store(store).type_credit.last
    _arr = {}
    _arr[:opening_stock]            = opening_stock.present? ? opening_stock.stock : 0
    _arr[:closing_stock]            = closing_stock.present? ? closing_stock.stock : 0
    _arr[:unit_price]      = current_stock_price.present? ? current_stock_price.unit_price : 0
    return _arr
  end

  def self.get_store_stock_report(store, from_date, to_date)
    total_credit_value = Stock.set_store(store).check_stock_date(from_date,to_date).type_credit.sum(:price)
    total_purchase_credit = Stock.set_store(store).check_stock_date(from_date,to_date).type_credit.set_transaction_type("StockPurchase").sum(:price)
    total_transfer_credit_value = Stock.set_store(store).check_stock_date(from_date,to_date).type_credit.set_transaction_type("StockTransfer").sum(:price)
    total_cost_of_transfer = Stock.set_store(store).check_stock_date(from_date,to_date).type_debit.set_transaction_type("StockTransfer").sum(:price)
    audit_consumption_price = Stock.set_store(store).check_stock_date(from_date, to_date).type_debit.set_transaction_type("StockAudit").sum(:price)
    audit_credit_proce = Stock.set_store(store).check_stock_date(from_date, to_date).type_credit.set_transaction_type("StockAudit").sum(:price)
    _arr = {}
    _arr[:total_credit_value]           = total_credit_value.present? ? total_credit_value : 0
    _arr[:total_transfer_credit_value]  = total_transfer_credit_value.present? ? total_transfer_credit_value : 0
    _arr[:total_cost_of_transfer]       = total_cost_of_transfer.present? ? total_cost_of_transfer : 0
    _arr[:total_purchase_credit]        = total_purchase_credit.present? ? total_purchase_credit : 0
    _arr[:audit_consumption_price]      = audit_consumption_price.present? ? audit_consumption_price : 0
    _arr[:audit_credit_proce]           = audit_credit_proce.present? ? audit_credit_proce : 0
    return _arr
  end

  def self.get_product_consumption_stock_report(store, product, from_date, to_date)
    opening_stock = StockUpdate.by_store(store).by_product(product).where('created_at <(?)',from_date).last
    closing_stock = StockUpdate.by_store(store).by_product(product).where('created_at <=(?)',to_date).last
    total_debit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_debit)
    total_credit = Stock.set_store(store).get_product(product).check_stock_date(from_date, to_date).sum(:stock_credit)
    
    _arr = {}
    _arr[:opening_stock]              = opening_stock.present? ? opening_stock.stock : 0
    _arr[:closing_stock]              = closing_stock.present? ? closing_stock.stock : 0
    _arr[:total_credit]               = total_credit.present? ? total_credit : 0
    _arr[:total_debit]                = total_debit.present? ? total_debit : 0
    return _arr
  end

  def self.consumption_to_csv stocks
    CSV.generate do |csv|
      csv << ["Product", "Total Stock Consumed"]
      stocks.each do |object|
        csv << ["#{object.product.name}", "#{object.total_debit} #{object.product.basic_unit}"]
      end
    end
  end
  def self.check_stock_status(_store_id,stock_filter,unit_id)
    if stock_filter.present?
      _pro_arr = Array.new
      if stock_filter == "1" || stock_filter == "2"
        latest_stock_update_ids = StockUpdate.where(["store_id = ?", _store_id]).group(:product_id).maximum(:id).values
        _updates = StockUpdate.where(["id IN(?) and stock > 0", latest_stock_update_ids])
        _updates.each do |up|
          _pro_arr.push(up.product_id)
        end
        if stock_filter == "1"
          where('products.id IN(?)',_pro_arr)
        elsif stock_filter == "2"
          where('products.id NOT IN(?)',_pro_arr) 
        end
      elsif stock_filter == "3"
        _menu_products = MenuManagement::get_activated_menu_products(unit_id)
        _menu_products.each do |mp|
          _pro_arr.push(mp.product_id)
        end
        where('products.id IN(?)',_pro_arr)
      end
    else
      all
    end    
  end

  def self.check_stock_status_for_barcode_enabled(stock_filter,_store_id,unit_id)
    if stock_filter == "1"
      where('available_stock > 0')
    elsif stock_filter == "2"
      where('available_stock = 0')
    elsif stock_filter == "3"
      _menu_products = MenuManagement::get_activated_menu_products(unit_id)
      _menu_products.each do |mp|
        _pro_arr.push(mp.product_id)
      end
      where('products.id IN(?) and store_id = ?',_pro_arr,_store_id)
    else  
      all 
    end
  end

  def self.filter_by_sku(sku)
    if sku.present?
      where("stocks.sku LIKE (?)","%#{sku}%")
    end
  end

  def self.filter_by_product_name(stocks,product_name)
    if product_name.present?
      stocks.joins(:product).where('lower(products.name) LIKE ?', "%#{product_name.downcase}%")
    end
  end

  def self.filter_by_product_id(stocks,product_id)
    if product_id.present?
      stocks.joins(:product).where('products.id = ?', product_id)
    end
  end

  def self.filter_by_product_category(stocks,product_categories)
    if !product_categories.empty?
      pro_cat_arr = Array.new
      product_categories.each do |product_category|
        pro_cat_arr = pro_cat_arr + Category.get_all_subcategories(product_category)
      end
      stocks.joins(:product).where('products.category_id IN(?)',pro_cat_arr)
    else
      all
    end    
  end

  def self.unit_wise_stock_purchase_to_csv(stock_purchase,product_details)
    CSV.generate do |csv|
      csv << ["Purchase Id", "Products", "Basic Unit", "Stock Purchase","Cost","Purchase to store","Vendor", "PO Sent on", "System PO Received on", "Invoice Date"]
      stock_purchase.each do |object|
        _invoice_date = object.stock_transaction.invoice_date.present? ? object.stock_transaction.invoice_date.strftime("%d %b %Y, %I:%M %p") : "-"
        csv << ["#{object.stock_transaction.id}", "#{object.product.name}", object.product.basic_unit, "#{object.stock_credit} #{object.product.basic_unit}", "#{object.price.to_f}","#{object.store.name}" "(Branch: #{object.store.unit.unit_name})", "#{object.stock_transaction.purchase_order.vendor.name}", object.stock_transaction.created_at.strftime("%d %b %Y, %I:%M %p"), "#{object.created_at.strftime('%d-%^b-%Y, %I:%M %p')}", _invoice_date]
      end
      _blank = Array.new
      _blank.push()
      csv<<_blank
      csv << ["Product","Total Stock Purchase","Total Cost"]
      product_details.each do |data|
        csv << ["#{data.product.name}","#{data.total_credit}","#{data.total_price.to_f}"]
      end
    end
  end

  def self.unit_wise_stock_transfer_to_csv(stock_transfer,product_details)
    CSV.generate do |csv|
      csv << ["Stock ID", "Products", "Basic Unit", "Stock transfered","Cost","Transfered from store","Transfered to store", "Date"]
      stock_transfer.each do |object|
        csv << ["#{object.id}", "#{object.product.name}", object.product.basic_unit, "#{object.stock_debit}", "#{object.price}","#{object.stock_transaction.from_store.name}", "#{object.stock_transaction.to_store.name}", "#{object.created_at.strftime('%d-%^b-%Y, %I:%M %p')}"]
      end
      _blank = Array.new
      _blank.push()
      csv<<_blank
      csv << ["Product","Total Stock Transfered","Total Cost"]
      product_details.each do |data|
        csv << ["#{data.product.name}","#{data.total_debit}","#{data.total_price}"]
      end
    end
  end

  def self.stock_transfer(stocks,transfer_type)
    if transfer_type == "credit"
      stocks = stocks.type_credit
      _store_type = stocks.present? ? Store.find(stocks.first.store_id).store_type : ''
      CSV.generate do |csv|
        if _store_type == "waste_bin"
          csv << ["Id", "Product", "Stock received", "Cost", "Received from", "Transfer Reason", "Transfer Code", "Date"]
        else
          csv << ["Id", "Product", "Stock received", "Cost", "Received from", "Date"]
        end
        stocks.each do |object|
          if _store_type == "waste_bin"
            _transfer_reason = object.stock_transaction.stock_transfer_meta.by_product(object.product_id).first.reason_code
            csv << ["#{object.id}", "#{object.product.name}", "#{object.stock_credit}","#{object.price}","#{object.stock_transaction.from_store.name}(Branch: #{object.stock_transaction.from_store.unit.unit_name})",_transfer_reason.reason,_transfer_reason.code,"#{object.created_at.strftime("%d %b %Y, %I:%M %p")}"]
          else
            csv << ["#{object.id}", "#{object.product.name}", "#{object.stock_credit}","#{object.price}","#{object.stock_transaction.from_store.name}(Branch: #{object.stock_transaction.from_store.unit.unit_name})","#{object.created_at.strftime("%d %b %Y, %I:%M %p")}"]
          end
        end
      end
    elsif transfer_type == "debit"
      stocks = stocks.type_debit
      CSV.generate do |csv|
        csv << ["Id", "Product", "Stock transfered", "Cost", "Transfered to store", "Date"]
        stocks.each do |object|
          csv << ["#{object.id}", "#{object.product.name}", "#{object.stock_debit}","#{object.price}","#{object.stock_transaction.to_store.name}(Branch: #{object.stock_transaction.to_store.unit.unit_name})","#{object.created_at.strftime("%d %b %Y, %I:%M %p")}"]
        end
      end
    end
  end

  def self.avaliable_stock_to_csv(stocks)
    CSV.generate do |csv|
      total_stock = 0
      total_unit_price = 0
      total_stock_price = 0
      csv << ["Stock ID", "Category","Products", "Basic Unit", "SKU", "Color", "Size", "Available Stock", "Price (incl. Tax)/unit", "Total Price (incl. Tax)"]
      stocks.each do |object|

        total_stock = total_stock + object.available_stock
        _price = object.stock_price.present? ? object.stock_price.landing_price==nil ? 0 : object.stock_price.landing_price : 0
        total_unit_price = total_unit_price + _price
        total_price = (object.available_stock * _price)
        total_stock_price = total_stock_price + total_price
        csv << ["#{object.id}","#{Category.find_by_id(object.product.category_id).name}", "#{object.product.name}", object.product.basic_unit, "#{object.sku}", object.color_name, object.size_name, "#{object.available_stock}","#{_price}","#{total_price}"]
      end
      csv << ["Total", "-", "-", "-", "-", "-", "#{total_stock}","#{total_unit_price.to_f.round(2)}","#{total_stock_price.to_f.round(2)}"]
    end
  end

  def self.avaliable_stock_of_period_to_csv(stocks,store,to_datetime)
    CSV.generate do |csv|
      total_stock = 0
      total_unit_price = 0
      total_stock_price = 0
      csv << ["Category","Products", "Basic Unit", "SKU", "Available Stock"]
      stocks.each do |object|

        product = Product.find(object.product_id)
        total_debit = Stock.select("COALESCE(sum(stock_debit),0) total_debit").by_product_sku(object.sku).by_product(object.product_id).set_store(store.id).type_debit.check_date(to_datetime)
        total_credit = object.total_credit.to_i
        total_debit = total_debit[0]["total_debit"].to_i
        available_stock = total_credit - total_debit
        csv << ["#{product.category.name}", "#{product.name}", product.basic_unit, "#{object.sku}", "#{available_stock}""#{product.basic_unit}"]
      end
    end
  end

  # Get price of an stock entry by quantity
  def get_price quantity
    price = (self.price.to_f / self.stock_credit.to_f) * quantity
  end

  # Fix current stock mismatch issue
  def self.fix_current_stock(store_id)
    products = Product.all
    products.each do |product|
      stock = Stock.get_product(product.id).set_store(store_id).last
      if stock.present?
        available_stock = Stock.get_product(product.id).set_store(store_id).available.sum(:available_stock)
        last_update = StockUpdate.by_product(product.id).by_store(store_id).last
        puts "Product #{product.name}, stock: #{available_stock}"
        last_update.update_attributes(:stock => available_stock, :sku_stock => nil)
      end
    end
    return store_id
  end

  def self.product_total_stock(product,store_ids)
    # Stock.select("sum(available_stock) as pro_total_stock").group("id").set_store_in(store_ids).get_product(product).available.type_credit.first
    stock  = Stock.set_store_in(store_ids).get_product(product).available.type_credit.sum(:available_stock)
    return stock
  end
  
  def self.product_stock_in_store(product,store)
    Stock.get_product(product).set_store(store).available.sum(:available_stock)
  end

  def self.current_stock_cost(store, product)
    Stock.select("sum(price * available_stock/stock_credit) as current_price").group(:id).get_product(product).set_store(store).type_credit.available.first
  end
  def self.cost_of_material_csv_report(stocks)
    CSV.generate do |csv|
      csv_header=["Material Name","Quantity","Cost (in #{@currency})"]
      csv<<csv_header
      stocks.each do |stocks|
        basic_unit=ProductUnit.select(:name).where("product_basic_unit_id=?",stocks.product.basic_unit_id).first
        csv<<["#{stocks.product.name}","#{stocks.stock_debit} #{basic_unit.name}","#{stocks.cost}"]
      end
    end
  end
  def self.stock_expiry_csv_report(stock_expires)
    CSV.generate do |csv|
      csv_header=["Stock Id","Product Name","Stock Created At","Available Stock","Expires On"]
      csv<<csv_header
      stock_expires.each do |stock|
        csv<<[stock.id,stock.product.name,stock.created_at.strftime("%Y-%m-%d"),"#{stock.available_stock} #{stock.product.basic_unit}",stock.expiry_date]
      end
    end
  end
  def self.stock_in_hand_to_csv(products, stores, from_datetime, to_datetime)
    CSV.generate do |csv|
      store_array = Array.new
      product_array = Array.new
      stock_array = Array.new
      store_array.push('')
      product_array.push('Products')
      product_array.push('Basic Unit')
      stores.each do |store|
        store_array.push("",store.name,"")
        product_array.push("Stock Credit", "Stock Debit", "Current Stock")
      end  
      csv << store_array
      csv << product_array
      products.each do |product|
        stock_array.push(product.name)
        stock_array.push(product.basic_unit)
        stores.each do |store|
          stock_data = Stock.get_stock_data(product.id,store.id,from_datetime,to_datetime)
          stock_array.push("#{stock_data[:total_credit]}","#{stock_data[:total_debit]}","#{stock_data[:current_stock]}" " (#{product.basic_unit})")
        end
        csv << stock_array
        stock_array.clear
      end  
    end
  end 

  private

  def generate_sku
    sku = format('%06d', self.id)
    stock = Stock.find(self.id)
    if (stock.sku.nil? || stock.sku == '') && (stock.product.business_type != "by_catalog")
      stock.update_column :sku, sku
    end
  end

  def update_stock_counter
    StockUpdate.update_product_stock(self.store_id,self.product_id,self.stock_credit,self.stock_debit,self.id,self.sku)
  end

  def check_safety_stock_level
    _daily_usages = Stock.select("sum(stock_debit) as stock_debit").group("date(created_at)").set_store(self.store_id).get_product(self.product_id).order("date(created_at)").last_month
    _max_daily_usage = _daily_usages.max_by(&:stock_debit).stock_debit
    _avg_daily_usage = _daily_usages.map { |x| x.stock_debit.to_f}.inject(:+) / _daily_usages.length
    _safety_stock = _max_daily_usage - _avg_daily_usage
    _reorder_level = _safety_stock + _avg_daily_usage
    _current_stock = StockUpdate.current_stock(self.store_id, self.product_id)
    if self.product.thresh_hold.present?
      if _current_stock.to_f < self.product.thresh_hold.to_f
        Notification.new_notification("#{self.product.name} crossed thresh hold limit","Current stock of #{self.product.name} (#{_current_stock} #{self.product.basic_unit}) crossed the thresh hold limit (#{self.product.thresh_hold} #{self.product.basic_unit}).",'inventory',"/notifications/thresh_hold_alerts",self.store.unit_id,nil,'high') if AppConfiguration.get_config_value('threshold_audit_alert') == 'enabled'
      elsif _current_stock.to_f < _reorder_level.to_f
        Notification.new_notification("#{self.product.name} at Reorder Level","Current stock of #{self.product.name} (#{_current_stock} #{self.product.basic_unit}) reached reorder level (#{_reorder_level} #{self.product.basic_unit}).",'sale',"#",self.store.unit_id,nil,'medium') if AppConfiguration.get_config_value('stock_reorder_level_alert') == 'enabled'
      end
    else
      if _current_stock.to_f < _safety_stock.to_f
        Notification.new_notification("#{self.product.name} crossed safety stock limit","Current stock of #{self.product.name} (#{_current_stock} #{self.product.basic_unit}) crossed the safety stock limit (#{_safety_stock} #{self.product.basic_unit}).",'sale',"#",self.store.unit_id,nil,'high') if AppConfiguration.get_config_value('safety_stock_alert') == 'enabled'
      elsif _current_stock.to_f < _reorder_level.to_f
        Notification.new_notification("#{self.product.name} at Reorder Level","Current stock of #{self.product.name} (#{_current_stock} #{self.product.basic_unit}) reached reorder level (#{_reorder_level} #{self.product.basic_unit}).",'sale',"#",self.store.unit_id,nil,'medium') if AppConfiguration.get_config_value('stock_reorder_level_alert') == 'enabled'
      end
    end
  end

  def check_thresh_hold_stock(_store_id,_product_id)
    # _daily_usages = Stock.select("sum(stock_debit) as stock_debit").group("date(created_at)").set_store(_store_id).get_product(_product_id).order("date(created_at)").last_month
    # _max_daily_usage = _daily_usages.max_by(&:stock_debit).stock_debit
    # _avg_daily_usage = _daily_usages.map { |x| x.stock_debit.to_f}.inject(:+) / _daily_usages.length
    # _safety_stock = _max_daily_usage - _avg_daily_usage
    # _reorder_level = _safety_stock + _avg_daily_usage
    # _current_stock = StockUpdate.current_stock(self.store_id, self.product_id)
    # return _current_stock
    # if _current_stock.to_f < self.product.thresh_hold.to_f
    #   Notification.new_notification("#{self.product.name} crossed safety stock limit","Current stock of #{self.product.name} (#{_current_stock} #{self.product.basic_unit}) crossed the safety stock limit (#{self.product.thresh_hold} #{self.product.basic_unit}).",'inventory',"#",self.store.unit_id,nil,'high') if AppConfiguration.get_config_value('safety_stock_alert') == 'enabled'
    # elsif _current_stock.to_f < _reorder_level.to_f
    #   Notification.new_notification("#{self.product.name} at Reorder Level","Current stock of #{self.product.name} (#{_current_stock} #{self.product.basic_unit}) reached reorder level (#{_reorder_level} #{self.product.basic_unit}).",'inventory',"#",self.store.unit_id,nil,'medium') if AppConfiguration.get_config_value('stock_reorder_level_alert') == 'enabled'
    # end
  end

  def self.estimate_stock_consumption_price store_id, product_id, quantity
    _quantity_counter = quantity.to_f
    _price_counter = 0
    self.product_debit_options(store_id, product_id).each do |option|
      if _quantity_counter >= option.available_stock
        _price_counter += option.get_price option.available_stock
        _quantity_counter -= option.available_stock #Reduce counter
      else
        if _quantity_counter > 0
          _price_counter += option.get_price _quantity_counter
          _quantity_counter = 0 #Reduce counter to zero
        end
      end
    end
    _price_counter
  end

  def check_expiry_date
    if AppConfiguration.get_config_value('stock_expiry_alert') == 'enabled'
      @dates = []
      _stock_expires_upto = AppConfiguration.get_config('stock_expires_upto').present? ? AppConfiguration.get_config('stock_expires_upto').to_i : 7
      (Date.today..Date.today+_stock_expires_upto).each { |_date| @dates.push _date }
      Stock.type_credit.get_expiry_date_in(@dates).each do |expiring_stock|
        unless Notification.set_notification_source_type('Stock').set_notification_source_id(expiring_stock.id).set_type('inventory_stock_expire').present?
          Notification.new_notification("Expiry of #{expiring_stock.product.name}", "#{expiring_stock.product.name} will be expired on #{expiring_stock.expiry_date}","inventory_stock_expire","#",expiring_stock.store.unit_id,nil,'high','Stock',expiring_stock.id)
        end
      end
    end
  end

  def update_stock_identity
    stock_identity = "#{self.created_at.strftime("%d-%m-%Y")}-#{self.product_id}-#{self.store_id}-#{self.id}"
    update_attribute(:stock_identity, stock_identity) if self.stock_transaction_type == "StockPurchase"
  end

  def update_batch_no
    if self.stock_transaction_type == "StockPurchase" and AppConfiguration.get_config_value('auto_generate_batch_no') == 'enabled' and (self.batch_no == nil or self.batch_no == '')
      puts "sdm,ksdds sdkjkjds sdkjsdkj"
      puts self.batch_no
      puts "skkskd dsksdksd ksdkds dsksdk"
      batch_no = "#{self.product_id}-#{self.created_at.strftime("%m%d%Y")}-#{self.stock_transaction.purchase_order.vendor.id}-#{self.id}"
      update_attribute(:batch_no, batch_no)
    end  
  end

end