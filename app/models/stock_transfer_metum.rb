class StockTransferMetum < ActiveRecord::Base
  attr_accessible :is_stock_debited, :price_with_tax, :price_without_tax, :quantity_transfered, :quantity_received, :tax_amount, :tax_group_id, :is_transferable, :product_id, :status, :product_transaction_unit_id, :stock_identity, :stock_id, :reason_code_id, :reason_code

  belongs_to :stock_transfer
  belongs_to :product
  belongs_to :tax_group
  belongs_to :reason_code

  before_validation :set_attributes
  before_save :update_ingredients, if: :should_transfer_ingredients?

  delegate :name, :basic_unit, to: :product, prefix: true, allow_nil: true

  default_scope {order(id: :asc)}

  # Model Scopes
  scope :by_product, lambda {|product_id|where(["product_id=?", product_id])}

  def issue_stock
    return if should_transfer_ingredients?
    if self.stock_id.present?
      puts self.stock_id
      if sufficient_in_stock? nil,self.stock_id
        cost = Stock.reduce_product_stock_by_stock_id(self.stock_id,self.quantity_transfered,self.stock_transfer_id,"stock_transfer",self.sale_price_without_tax)
        stock_issued!
      else
        raise I18n.t(:error_insufficient_stock_for_transfer, items: self.product_name)
      end
    else  
      if sufficient_in_stock? self.stock_transfer.primary_store_id, nil
        cost = Stock.reduce_product_stock(self.stock_transfer.primary_store_id,self.product_id,self.quantity_transfered,self.stock_transfer_id,"stock_transfer",self.sku,self.model_number,self.size_name,self.color_name, self.sale_price_without_tax,self.color_id,self.size_id,self.batch_no)
        stock_issued!
      else
        raise I18n.t(:error_insufficient_stock_for_transfer, items: self.product_name)
      end
    end
    lot = Lot.find_by_product_id_and_sku_and_store_id_and_sell_price_without_tax_and_expiry_date(self.product_id,self.sku,self.stock_transfer.primary_store_id,self.sale_price_without_tax,self.expery_date)
    if lot.present? && lot.mode == 0
      stock_qty = lot.stock_qty - self.quantity_transfered
      lot.update_attributes(:stock_qty => stock_qty)
    end
  end

  def credit_stock
    return if should_transfer_ingredients?
    issue_stock if stock_not_issued_yet? # Issue stock from source store if not issued yet
    stock = Stock.credit(self.product_id, self.stock_transfer.secondary_store_id, self.price_with_tax, self.quantity_received || self.quantity_transfered, 'StockTransfer', self.stock_transfer_id, self.sku, self.model_number, self.size_name, self.color_name, self.sale_price_without_tax,self.color_id,self.size_id,self.batch_no,self.stock_identity)
    if AppConfiguration.get_config_value('retail_menu') == 'enabled' && AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
      if UnitProduct.by_unit(self.stock_transfer.to_store.unit_id).by_product(self.product_id).present?
        up = UnitProduct.by_unit(self.stock_transfer.to_store.unit_id).by_product(self.product_id).first
        _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
        _total_amnt = 0
        i = 1
        @tax_array = up.tax_group.tax_classes
        @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
        @tax_array.each do |tc|
          if tc.tax_type == 'variable'
            if self.sale_price_without_tax.to_f <= _limit_vtax
              if i == 1
                _total_amnt = _total_amnt + 2.5    
              elsif i == 2
                _total_amnt = _total_amnt + 2.5
              end
            else
              if i == 3
                if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                  _total_amnt = _total_amnt + 9
                else    
                  _total_amnt = _total_amnt + 6
                end 
              elsif i == 4
                if tc.ammount.to_f == 9.00 || tc.ammount.to_f == 9
                  _total_amnt = _total_amnt + 9
                else    
                  _total_amnt = _total_amnt + 6
                end 
              end
            end
          else
            _total_amnt = _total_amnt + tc[:ammount].to_f  
          end
          i += 1
        end
        sell_price_without_tax = 0
        sell_price_without_tax = (self.sale_price_without_tax.to_f * 100)/(_total_amnt.to_f + 100)
        if self.batch_no.present?
          lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(up.product_id,self.sku,self.expery_date,sell_price_without_tax,self.batch_no,0,self.stock_transfer.secondary_store_id)
        else
          lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(up.product_id,self.sku,self.expery_date,sell_price_without_tax,0,self.stock_transfer.secondary_store_id)
        end  
        if lot.present?
          stock_qty = lot.stock_qty + self.quantity_received
          lot.update_attributes(:stock_qty => stock_qty)
        else
          lot = Lot.new
          lot.unit_product_id = up.id
          lot.mode = 0
          lot.sell_price = self.sale_price_without_tax
          lot.sell_price_without_tax = sell_price_without_tax
          lot.sku = self.sku
          lot.stock_qty = self.quantity_received
          lot.product_id = self.product_id
          lot.expiry_date = self.expery_date
          lot.stock_id = stock.id
          lot.procured_price = self.procurment_price
          lot.mrp = self.mrp
          lot.size_name = self.size_name
          lot.color_name = self.color_name
          lot.color_id = self.color_id
          lot.size_id = self.size_id
          lot.batch_no = self.batch_no
          lot.store_id = self.stock_transfer.secondary_store_id
          lot.save
        end  
      end
    end
  end

  # Check if an item is present in stock or not.
  def item_in_stock? stock_of_items, primary_store_id
    if insufficient_in_stock? primary_store_id
      if not_deleted!
        stock_of_items[:insufficient_items].push self.product_name
      end
    end
  end

  # Check if an item has sufficient stock in inventory or not
  def sufficient_in_stock? primary_store_id = nil,stock_id = nil
    if primary_store_id != nil
      current_stock = StockUpdate.current_stock(primary_store_id, self.product_id)
    else
      current_stock = Stock.find(stock_id).available_stock
    end   

    (self.quantity_transfered <= current_stock) ? true : false
  end

  def insufficient_in_stock? primary_store_id
    !sufficient_in_stock? primary_store_id
  end

  def stock_issued?
    self.is_stock_debited
  end

  def stock_not_issued_yet?
    !stock_issued?
  end

  def stock_issued!
    update_attributes(:is_stock_debited => true)
  end

  def not_deleted!
    self._destroy == 1 ? true : false
  end

  def calculate_tax_amount
    tax = (self.price_without_tax * self.tax_group.total_amnt / 100) + self.tax_group.fixed_amount
    tax.round(2)
  end

  def transferable?
    is_transferable
  end

  def should_transfer_ingredients?
    !transferable?
  end

  def product_ingredients
    self.product.product_compositions
  end

  def initiate_production_audit
    if should_transfer_ingredients?
      new_audit = KitchenProductionAudit.new(:store_id => self.stock_transfer.secondary_store_id, :product_id => self.product_id, :received_qty=> self.quantity_transfered, :status=>"1")
      self.stock_transfer.production_audits << new_audit
    end
  end

  private

    def set_attributes
      self.price_without_tax = self.price_without_tax.present? ? self.price_without_tax : 0
      self.tax_amount = (self.price_without_tax.present? and self.tax_group_id.present?) ? calculate_tax_amount : 0
      self.price_with_tax = (self.price_without_tax.round(2) + self.tax_amount.round(2)) if self.price_without_tax.present?
      self.quantity_received ||= self.quantity_transfered
    end

    def update_ingredients
      if product_ingredients.present?
        product_ingredients.each do |e|
          item_quantity = self.quantity_transfered_changed? ? ((self.quantity_transfered - self.quantity_transfered_was) * e.inventory_quantity.to_f) : (self.quantity_transfered * e.inventory_quantity.to_f)
          self.stock_transfer.add_item_for_transfer(e.raw_product_id, item_quantity)
        end
      end
    end
end
