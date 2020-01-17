class StockAudit < ActiveRecord::Base
  attr_accessible :status, :store_id, :audit_done_by, :audit_reviewed_by, :business_type

  # => Defining relations
  belongs_to :store
  belongs_to :audit_user, :class_name => "User", :foreign_key => "audit_done_by"
  belongs_to :audit_review_user, :class_name => "User", :foreign_key => "audit_reviewed_by"
  has_many :stock_audit_metas
  has_many :stocks, as: :stock_transaction

  # => Model validations
  validates :store_id, :presence => true
  validates :status, :presence => true
  
  # => Model scopes
  scope :desc_order, lambda { order("created_at desc") }
  scope :pending_audit, lambda { where(:status => '1') }
  scope :approved_audit, lambda { where(:status => '2') }
  scope :set_store_in, lambda {|store_ids|where(["store_id in (?)", store_ids])}


  # => Model callbacks
  after_create :notify_users_for_audit

  def self.initiate_audit_procedure(store_id,selected_products,current_user_id,business_type)
    _new_audit = StockAudit.create(:store_id => store_id, :status => "1", :audit_done_by=> current_user_id, :business_type => business_type)
    if business_type == "by_catalog"
      if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
        selected_products.each do |slp|
          #_stock = Stock.find(slp[:stock_id])
          #_current_stock = _stock.available_stock
          if AppConfiguration.get_config_value('stock_identity') == 'enabled'
            _stock_id = slp[:stock_id]
            # stocks = Stock.available.set_store(store_id).where("product_id = ? and stock_identity = ?", slp[:product_id],slp[:stock_identity])
            stocks = Stock.where(:id=>_stock_id)
            # _current_stock = Stock.get_product(slp[:product_id]).set_store(store_id).by_stock_identity(slp[:stock_identity]).available.sum(:available_stock)
            _current_stock = Stock.find(_stock_id).available_stock
          else
            condition_hash = slp.clone
            condition_hash[:color_id]= [nil,''] if condition_hash[:color_id] == nil
            condition_hash[:size_id]= [nil,''] if condition_hash[:size_id] == nil
            condition_hash[:model_number]= [nil,''] if condition_hash[:model_number] == nil
            condition_hash[:batch_no]= [nil,''] if condition_hash[:batch_no] == nil
            #condition_hash  = condition_hash.except!(:quantity,:transfer_meta_id)
            condition_hash  = condition_hash.except!(:quantity,:transfer_meta_id,:counted_stock)
            _current_stock = Stock.set_store(store_id).where(condition_hash).sum(:available_stock)
            puts "current_stock : #{_current_stock}"
            # stocks = Stock.available.set_store(store_id).select("").where("product_id = ? and sku = ?", slp[:product_id],slp[:sku])
            # _current_stock = Stock.get_product(slp[:product_id]).set_store(store_id).by_sku(slp[:sku]).available.sum(:available_stock)
          end
          # _stock = stocks.first
          _new_audit_meta = StockAuditMeta.new
          _new_audit_meta[:stock_audit_id] = _new_audit.id
          _new_audit_meta[:sell_price_with_tax] = slp[:sell_price_with_tax]
          _new_audit_meta[:product_id] = slp[:product_id]
          _new_audit_meta[:current_stock] = _current_stock
          _new_audit_meta[:counted_stock] = slp[:counted_stock]  #
          _new_audit_meta[:remarks] = slp[:remarks]
          _new_audit_meta[:delta_stock] = _current_stock.to_f - slp[:counted_stock].to_f
          _new_audit_meta[:reason_code] = slp[:reason_code]
          _new_audit_meta[:audit_options] = nil
          _new_audit_meta[:sku] = slp[:sku]
          _new_audit_meta[:model_no] = slp[:model_number]
          _new_audit_meta[:batch_no] = slp[:batch_no]
          _new_audit_meta[:size_id] = slp[:size_id]
          _new_audit_meta[:color_id] = slp[:color_id]
          # _new_audit_meta[:stock_identity] = _stock.stock_identity if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          # _new_audit_meta[:stock_id] = _stock.id if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          _new_audit_meta.save
        end
      else  
        selected_products.each do |slp|
          puts slp
          _current_stock = StockUpdate.current_stock(store_id, slp[:product_id])
          _new_audit_meta = StockAuditMeta.new
          _new_audit_meta[:stock_audit_id] = _new_audit.id
          _new_audit_meta[:product_id] = slp[:product_id]
          _new_audit_meta[:current_stock] = _current_stock
          _new_audit_meta[:delta_stock] = _current_stock.to_f - slp[:counted_stock].to_f
          _new_audit_meta[:counted_stock] = slp[:counted_stock]
          _new_audit_meta[:remarks] = slp[:remarks]
          _new_audit_meta[:reason_code] = slp[:reason_code]
          _new_audit_meta[:audit_options] = nil
          _new_audit_meta[:stock_identity] = slp[:stock_identity] if AppConfiguration.get_config_value('stock_identity') == 'enabled'
          _new_audit_meta.save
        end
      end
    else
      selected_products.each do |slp|
        _current_stock = StockUpdate.current_sku_stock(store_id, slp[:product_id], slp[:sku])
        _new_audit_meta = StockAuditMeta.new
        _new_audit_meta[:stock_audit_id] = _new_audit.id
        _new_audit_meta[:product_id] = slp[:product_id]
        _new_audit_meta[:current_stock] = _current_stock
        _new_audit_meta[:counted_stock] = slp[:counted_stock]
        _new_audit_meta[:remarks] = slp[:remarks]
        _new_audit_meta[:reason_code] = slp[:reason_code]
        _new_audit_meta[:audit_options] = nil
        _new_audit_meta[:sku] = slp[:sku]
        _new_audit_meta.save
      end
    end 
    return _new_audit 
  end

  def self.approve_audit(_status,stock_audit,products)
    puts products
    if _status == "2"
      stock_audit.stock_audit_metas.each do |sam|
        _current_stock_date = StockUpdate.by_product(sam.product_id).by_store(stock_audit.store_id).last.created_at
        puts _current_stock_date
        _current_stock = StockUpdate.current_stock(stock_audit.store_id,sam.product_id)
        if _current_stock_date > sam.created_at
          sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
        else
          _stock_to_consume = (_current_stock.to_f - sam.counted_stock.to_f)
          if _stock_to_consume <= 0 
            if _stock_to_consume == 0
              sam.update_attributes(:stock_added => 0,:stock_consumed => 0, :current_stock_at_review => _current_stock)
            else
              
              products.each do |product|
                if product[:product_id].to_i == sam.product_id
                  Stock.save_stock(sam.product_id,stock_audit.store_id,product[:price],product[:stock],stock_audit.id,'stock_audit',product[:stock],0,nil,nil,nil)
                  sam.update_attributes(:stock_added => product[:stock].to_f, :current_stock_at_review => _current_stock)
                end
              end
            end
          else
            Stock.reduce_product_stock(stock_audit.store_id,sam.product.id,_stock_to_consume,stock_audit.id,"stock_audit")
            sam.update_attributes(:stock_consumed => _stock_to_consume, :current_stock_at_review => _current_stock)
          end
        end
      end #End of product for each
    end
  end

  def self.by_date(from_date, upto_date)
    if from_date.present? && upto_date.present?
      where('created_at BETWEEN ? AND ?',from_date,upto_date)
    else
      all
    end
  end
  
  private
  
  # => New notification for audit
  def notify_users_for_audit
    Notification.new_notification("New stock audit","A new stock audit done at #{self.store.name}, please review.",'inventory',"#",self.store.unit_id,nil,'high') if AppConfiguration.get_config_value('stock_audit_alert') == 'enabled'
  end  
end
