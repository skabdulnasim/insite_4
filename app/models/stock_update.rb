class StockUpdate < ActiveRecord::Base
  attr_accessible :product_id, :stock, :store_id, :stock_ref_id, :sku, :sku_stock
  
  # => Defining relations
  belongs_to :store
  belongs_to :product

  # => Model Validations
  validates :product_id, :presence => true
  validates :stock, :presence => true
  validates :store_id, :presence => true

  # => Model Callbacks
  after_create :push_update_to_subscribers
  after_create :update_menu_product_stock
  # => Model scopes
  scope :by_product, lambda {|product_id|where(["product_id=?", product_id])}
  scope :get_product_in,lambda {|product_ids|where(["product_id in (?)", product_ids])}
  scope :by_store, lambda {|store_id|where(["store_id=?", store_id])}
  scope :last_day, lambda { where(["created_at > ?",1.day.ago]) }
  scope :last_week, lambda { where(["created_at > ?",1.week.ago]) }
  scope :last_month, lambda { where(["created_at > ?",1.month.ago]) }
  scope :set_store_in, lambda {|store_ids|where(["store_id in (?)", store_ids])}
         

  def self.in_stock_products(_store_id)
    latest_stock_update_ids = StockUpdate.where(["store_id = ?", _store_id]).group(:product_id).maximum(:id).values
    _updates = StockUpdate.where(["id IN(?) and stock > 0", latest_stock_update_ids])
    return _updates
  end

  def self.current_stock(store_id, product_id)
    _last_update = StockUpdate.where(["store_id = ? and product_id = ?", store_id, product_id]).last
    if _last_update.present?
      return _last_update.stock
    else
      return 0
    end 
  end

  def self.current_sku_stock(store_id, product_id, sku)
    _last_update = StockUpdate.where(["store_id = ? AND product_id = ? AND cast(sku as text) = ?", store_id, product_id, "#{sku}"]).last
    if _last_update.present?
      return _last_update.sku_stock
    else
      product_stock = Stock.available_stock(product_id,store_id,sku)
      return product_stock
    end
  end

  def self.update_product_stock(store_id,product_id,stock_credit,stock_debit,_stock_id,sku)
    _current_stock = StockUpdate.current_stock(store_id,product_id)
    stock = Stock.find(_stock_id)
    if stock.stock_transaction_type == "StockAudit" && stock_credit.to_f == 0 && stock_debit.to_f == 0
      _new_stock = 0
    else  
      _new_stock = (_current_stock.to_f + stock_credit.to_f - stock_debit.to_f).round(5)
    end  
    _current_sku_stock = StockUpdate.current_sku_stock(store_id,product_id,sku)
    _new_sku_stock = (_current_sku_stock.to_f + stock_credit.to_f - stock_debit.to_f)
    StockUpdate.create(:store_id => store_id, :product_id=> product_id, :stock=>_new_stock, :stock_ref_id=>_stock_id, :sku=>sku, :sku_stock=>_new_sku_stock)
  end
  
  private
  
  # => PUSH service for all subscribers
  def push_update_to_subscribers
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _store = Store.find(self.store_id)
    _channels=Array.new
    _channels.push '/notifications/android/subdomain/'+_subdomain.config_value.to_s+'/unit/'+_store.unit_id.to_s+'/store/'+self.store_id.to_s
    _hash = {:type => 'stock_update', :json_data => self}
    Notification.publish_in_faye(_channels,_hash)
  end

  def update_menu_product_stock
    _stock_status = self.stock > 0 ? 1 : 0
    MenuProduct.set_product(self.product_id).set_store(self.store_id).update_all(:stock_status => _stock_status,:stock_qty => self.stock)
  end
end
