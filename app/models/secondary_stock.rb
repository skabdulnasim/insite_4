class SecondaryStock < ActiveRecord::Base
  attr_accessible :available_stock, :current_stock, :product_id, :product_unit_id, :stock_credit, :stock_debit, :stock_id, :store_id

  belongs_to :stock
  belongs_to :product
  belongs_to :product_unit

  validates :stock_id,        :presence => true
  validates :product_id,      :presence => true
  validates :store_id,        :presence => true
  validates :stock_credit,    :presence => true
  validates :stock_debit,     :presence => true
  
  before_create :calculate_current_stock

  scope :by_store,        lambda {|store_id|where(["store_id=?", store_id])}
  scope :by_product,      lambda {|product_id|where(["product_id=?", product_id])}
  scope :by_product_unit, lambda {|unit_id|where(["product_unit_id=?", unit_id])}
  scope :available,       lambda { where("available_stock >?",0) }

  def self.credit _stock, _product_unit_id, _quantity
    self.set_attributes_for 'credit', _stock, _product_unit_id, _quantity
  end

  def self.debit stock, product_unit_id, quantity
    _stock = self.current_unit_stock(stock.store_id, stock.product_id, product_unit_id)
    raise "Item insufficient in stock" unless quantity <= _stock
    self.set_attributes_for 'debit', stock, product_unit_id, quantity
    _debit_options = self.debit_options stock.store_id, stock.product_id, product_unit_id
    _debit_options.each do |top|
      if quantity.to_f >= top.available_stock.to_f
        self.consume(top.id,top.available_stock.to_f)
        quantity = (quantity.to_f) - (top.available_stock.to_f)
      elsif quantity.to_f > 0
        self.consume(top.id,quantity.to_f)
        quantity = 0
      end
    end
  end
  
  def self.set_attributes_for type, stock, product_unit_id, quantity
    secondary_stock = SecondaryStock.new( :stock_id => stock.id,
                                          :store_id => stock.store_id,
                                          :product_id => stock.product_id,
                                          :product_unit_id => product_unit_id,
                                          :available_stock => (type == 'debit' ? 0 : quantity),
                                          :stock_credit => (type == 'debit' ? 0 : quantity),
                                          :stock_debit => (type == 'credit' ? 0 : quantity) )
    secondary_stock.save!        
  end

  def self.consume stock_id,quantity 
    _stock = SecondaryStock.find(stock_id)
    if _stock.available_stock.to_f > quantity.to_f
      @new_qty = _stock.available_stock - quantity
    else
      @new_qty = 0
      quantity = _stock.available_stock
    end
    _stock.update_attribute(:available_stock, @new_qty) #Update new available stock
    return quantity
  end

  def self.current_unit_stock(store_id, product_id, product_unit_id)
    _last_update = SecondaryStock.by_store(store_id).by_product(product_id).by_product_unit(product_unit_id)
    _stock = _last_update.present? ? _last_update.last.current_stock : 0
  end

  def self.current_stock_string store_id, product_id
    _units = SecondaryStock.select("DISTINCT(product_unit_id)").by_store(store_id).by_product(product_id)
    _units.present? ? _units.map{ |u| "#{SecondaryStock.current_unit_stock(store_id, product_id, u.product_unit_id)} #{u.product_unit.short_name}(s)" }.join(', ') : "N/A"
  end

  def self.debit_options store_id, product_id, product_unit_id
    SecondaryStock.available.by_store(store_id).by_product(product_id).by_product_unit(product_unit_id)
  end

  private

  def calculate_current_stock
    _current_stock = SecondaryStock.current_unit_stock(self.store_id,self.product_id,self.product_unit_id)
    self.current_stock = (_current_stock.to_f + self.stock_credit.to_f - self.stock_debit.to_f)
  end
end
