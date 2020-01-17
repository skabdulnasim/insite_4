class StockPurchase < ActiveRecord::Base
  attr_accessible :purchase_order_id, :status, :status_log, :store_id, :attachment, :total_amount, :paid_amount, :payment_status, :remarks, :invoice_date, :invoice_no, :invoice_amount, :grn_no, :travelling_cost, :discount_on_po
  
  has_attached_file :attachment, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/demo-po.png"
  validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\Z/
  
  # => Defining Relations
  has_many :stocks, as: :stock_transaction
  has_many :stock_purchase_payments
  belongs_to :store
  belongs_to :purchase_order
  
  # => Setting purchase attributes before_validation
  before_validation :set_purchase_attributes, on: :create
    
  # => Validations
  validates :purchase_order_id, :presence => true
  validates :status, :presence => true
  validates :store_id, :presence => true
  
  # => Scopes
  scope :pending_pos,   lambda { where(:status => "1") }
  scope :desc_order,    lambda { order("created_at desc") }
  scope :date_range,    lambda { |from_datetime,to_datetime| where(:updated_at=>from_datetime..to_datetime)}
  scope :received,      lambda { where(:status=>"2")}
  scope :partially_received,   lambda { where(:status=>"3")}
  scope :stores_in, lambda {|store_ids|where(["store_id in (?)", store_ids])}
  # scope :set_status, lambda {|status|where(["status=?", status])}
  scope :by_status, lambda {|status| where(["status=?", status])}
  scope :by_vendor, lambda {|vendor_id| joins(:purchase_order).merge(PurchaseOrder.by_vendor(vendor_id))}
  scope :set_po_ids_in, lambda {|po_ids| where(["purchase_order_id in (?)", po_ids])}
  scope :set_ids_in, lambda {|ids| where(["id in (?)", ids])}

  def self.stock_csv_upload(row, store_id,stock_transaction_id,stock_transaction_type)
    puts "CSV Upload data: #{row}"
    _product = Product.find_by_name(row[:product_name])
    if _product.business_type == "by_mrp"
      stock = Stock.save_stock(_product.id, store_id, row[:cog], row[:quantity], stock_transaction_id, stock_transaction_type,row[:quantity],0, nil,row[:sku],nil)
      sku = row[:sku].present? ? row[:sku] : format('%06d', stock.id)
      StockDefination.save_stock_defination(stock.id, nil, nil, nil, row[:mrp], 0, sku, row[:description])
    elsif _product.business_type == "by_weight"
      stock = Stock.save_stock(_product.id, store_id, row[:cog], row[:quantity], stock_transaction_id, stock_transaction_type, row[:quantity], 0, nil,row[:sku],nil)
      sku = row[:sku].present? ? row[:sku] : format('%06d', stock.id)
      StockDefination.save_stock_defination(stock.id, row[:weight], row[:product_unit_id], row[:making_cost], nil, row[:wastage], sku, row[:description])
    elsif _product.business_type == "by_bulk_weight"
      stock = Stock.save_stock(_product.id, store_id, row[:total_cog], row[:weight], stock_transaction_id, stock_transaction_type, row[:weight], 0, nil,row[:sku],nil)
      sku = row[:sku].present? ? row[:sku] : format('%06d', stock.id)
      StockDefination.save_stock_defination(stock.id, row[:weight], row[:product_unit_id], row[:total_making_cost], nil, row[:total_wastage], sku, row[:description])
    elsif _product.business_type == "by_catalog"
      stock = Stock.save_stock(_product.id, store_id, row[:cog], row[:quantity], stock_transaction_id, stock_transaction_type,row[:quantity],0, nil, nil,nil)
      StockDefination.save_stock_defination(stock.id, nil, nil, nil, row[:mrp], 0, nil, row[:description])
    end
  end

  def self.check_po_count_status(purchase_id,all_count,checked_count,received_count)
    if received_count.to_i+checked_count.to_i == all_count.to_i
      _purchase = StockPurchase.find(purchase_id)
      _purchase.update_attribute(:status, "2")
    end
  end

  # def self.update_purchase_status(_stock_purchase)
  #   _stock_count = _stock_purchase.stocks.count
  #   _po_items_count = _stock_purchase.purchase_order.purchase_order_metum.count
  #   if _stock_count >= _po_items_count
  #     _stat_log = _stock_purchase.status_log.present? ? JSON.parse(_stock_purchase.status_log) : Array.new
  #     _stat_log = Array.new if _stat_log.is_a?(Hash)
  #     _arr = {}
  #     _arr[:status_id] = "2"
  #     _arr[:status_short_desc] = "All purchase order items has been received"
  #     _arr[:time] = Time.now.strftime("%d-%m-%Y %H:%M")
  #     _stat_log.push(_arr)
  #     _stock_purchase.update_attributes(:status => "2", :status_log=>JSON.generate(_stat_log)) 
  #   else
  #     _stat_log = _stock_purchase.status_log.present? ? JSON.parse(_stock_purchase.status_log) : Array.new
  #     _stat_log = Array.new if _stat_log.is_a?(Hash)
  #     _arr = {}
  #     _arr[:status_id] = "3"
  #     _arr[:status_short_desc] = "Purchase order items has been partially received"
  #     _arr[:time] = Time.now.strftime("%d-%m-%Y %H:%M")
  #     _stat_log.push(_arr)
  #     _stock_purchase.update_attributes(:status => "3", :status_log=>JSON.generate(_stat_log)) 
  #   end
  # end

  def self.update_purchase_status(_stock_purchase)
    _stock_count = _stock_purchase.stocks.count
    _po_items_count = _stock_purchase.purchase_order.purchase_order_metum.count
    _po_items = _stock_purchase.purchase_order.purchase_order_metum
    _stocks_found = 1
    _po_items.each do |pom_item|
      # if !_stock_purchase.stocks.get_product(pom_item.product_id).present?
      #   _stocks_found = 0
      # end
      if _stock_purchase.stocks.get_product(pom_item.product_id).present?
        if _stock_purchase.stocks.get_product(pom_item.product_id).sum(:stock_credit).to_f < pom_item.product_amount.to_f
          _stocks_found = 0
        end
      else
        _stocks_found = 0
      end
    end
    if _stocks_found == 1
      _stat_log = _stock_purchase.status_log.present? ? JSON.parse(_stock_purchase.status_log) : Array.new
      _stat_log = Array.new if _stat_log.is_a?(Hash)
      _arr = {}
      _arr[:status_id] = "2"
      _arr[:status_short_desc] = "All purchase order items has been received"
      _arr[:time] = Time.now.strftime("%d-%m-%Y %H:%M")
      _stat_log.push(_arr)
      _stock_purchase.update_attributes(:status => "2", :status_log=>JSON.generate(_stat_log)) 
    else
      _stat_log = _stock_purchase.status_log.present? ? JSON.parse(_stock_purchase.status_log) : Array.new
      _stat_log = Array.new if _stat_log.is_a?(Hash)
      _arr = {}
      _arr[:status_id] = "3"
      _arr[:status_short_desc] = "Purchase order items has been partially received"
      _arr[:time] = Time.now.strftime("%d-%m-%Y %H:%M")
      _stat_log.push(_arr)
      _stock_purchase.update_attributes(:status => "3", :status_log=>JSON.generate(_stat_log)) 
    end
  end

  def self.update_payment_status(_stock_purchase)
    if _stock_purchase.status == "2"
      if _stock_purchase.total_amount == _stock_purchase.paid_amount
        _stock_purchase.update_attribute(:payment_status, "paid")
      end  
    end 
  end

  def self.set_status(status)
    if status.present?
      where('status=?',status)
    else
      all
    end
  end

  def self.to_csv(purchases)
    CSV.generate do |csv|
      csv << ["Stock Receive ID", "PO Reference","Vendor", "Products", "Total Tax", "Total Amount (Incl. Tax)", "PO Sent on", "System PO Received on", "Invoice Date"]
      purchases.each do |object|
        products = "#{object.stocks.map{|stock| stock.product.name + stock.stock_credit.to_s + stock.product.basic_unit}.join(" | ")}"
        total_tax = object.stocks.inject(0){|result, stock| result + stock.stock_taxes.inject(0){|data,stock_tax| data + stock_tax.tax_amount} }
        total_amount = object.stocks.inject(0){|result, stock| result + stock.price}
        _invoice_date = object.invoice_date.present? ? object.invoice_date.strftime('%d-%^b-%Y, %I:%M %p') : "-"
        csv << ["#{object.id}", "#{object.purchase_order.name} (ID: #{object.purchase_order.id})","#{object.purchase_order.vendor.name}","#{products}" ,"#{total_tax}","#{total_amount}",object.created_at.strftime('%d-%^b-%Y, %I:%M %p'),"#{object.updated_at.strftime('%d-%^b-%Y, %I:%M %p')}",_invoice_date]
      end
    end
  end

  def self.import(file,store_id,stock_transaction_id,stock_transaction_type,unit_id,total_rows)
    _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
    q = total_rows/100
    r = total_rows%100
    if q == 0
      counter = 1
    else
      if r == 0
        counter = q
      else
        counter = q + 1
      end
    end
    csv_file = CSV.read(file.path, headers: true)
    imported_stocks = Array.new
    data_errors = Array.new
    @stock_purchase = StockPurchase.find(stock_transaction_id)
    (0...counter).each do |outer_key|
      f_index = outer_key*100
      if outer_key == counter - 1
        l_index = total_rows - 1
      else
        l_index = (outer_key+1)*100 - 1
      end
      (f_index..l_index).each do |inner_key|
        row = csv_file[inner_key]
        if AppConfiguration.get_config_value('barcode_on_catalog_product') == 'enabled'
          stock_total_price = 0
          stock = Stock.new
          stock.attributes = row.to_hash.slice(*Stock.accessible_attributes)
          product = Product.find_by_id(row["Product"]) || Product.find_by_name(row["Product"])
          stock[:product_id] = product.id.present? ? product.id : nil
          stock[:store_id] = store_id.present? ? store_id : nil
          stock[:stock_transaction_id] = stock_transaction_id.present? ? stock_transaction_id : nil
          stock[:stock_transaction_type] = stock_transaction_type.present? ? stock_transaction_type : nil
          stock[:stock_debit] = 0
          stock[:expiry_date] = row["Expiry Date"].present? ? row["Expiry Date"] : "2040-04-02"
          stock[:mfg_date] = row["Mfg Date"].present? ? row["Mfg Date"] : Date.today.strftime("%Y-%m-%d")
          stock[:available_stock] = row["Quantity"]
          stock[:stock_credit] = row["Quantity"]
          stock_discount = row["Discount"].present? ? row["Discount"] : 0
          stock_additional_cost = row["Additional Cost"].present? ? row["Additional Cost"] : 0
          stock_total_price = row["Landing Price per unit"].to_f * row["Quantity"].to_f + stock_additional_cost.to_f - stock_discount.to_f
          stock[:price] = stock_total_price.to_f
          stock[:sku] = row["Sku"].present? ? row["Sku"] : product.sku
          stock[:model_number] = row["Model No"].present? ? row["Model No"] : nil
          stock[:batch_no] = row["Batch No"].present? ? row["Batch No"] : nil
          color = Color.find_or_create_by(name: row["Color"]) || Color.find_by_id(row["Color"]) if row["Color"].present? 
          color_id = color.present? ? color.id : nil
          color_name = color.present? ? color.name : nil
          stock[:color_name] = color_name
          stock[:color_id] = color_id
          size = Size.find_or_create_by(name: row["Size"]) || Size.find_by_id(row["Size"]) if row["Size"].present? 
          size_id = size.present? ? size.id : nil
          size_name = size.present? ? size.name : nil
          stock[:size_name] = size_name
          stock[:size_id] = size_id
          stock[:p_gender] = row["Product Gender"].present? ? row["Product Gender"] : nil
          stock[:sell_price_with_tax] = row["Sell price with tax"].present? ? row["Sell price with tax"] : nil
          total_price_without_tax = row["Landing Price per unit"].to_f * row["Quantity"].to_f - stock_discount.to_f
          tax_on_mrp_pc = row["Tax(%) on MRP"].present? ? row["Tax(%) on MRP"] : 0
          tax_on_landing_pc = row["Tax(%) on Landing"].present? ? row["Tax(%) on Landing"] : 0
          total_tax = 0
          if !tax_on_mrp_pc.nil? || tax_on_mrp_pc != 0
            total_tax = row["MRP"].to_f * 1.to_f * tax_on_mrp_pc.to_f / 100
          elsif !tax_on_landing_pc.nil? || tax_on_landing_pc != 0
            total_tax = row["Landing Price per unit"].to_f * row["Quantity"].to_f * tax_on_landing_pc.to_f / 100
          end
          total_price_with_tax = total_price_without_tax.to_f + total_tax.to_f + stock_additional_cost.to_f
          if stock.save
            product.update_attribute(:hsn_code, row["Hsn-code"])
            if AppConfiguration.get_config_value('uniqe_sku_for_stock') == 'enabled' 
              sku = row["Sku"].present? ? row["Sku"].strip : format('%010d', stock.id)
            elsif AppConfiguration.get_config_value('uniqe_stock_for_color_size') == 'enabled'
              _sku = "#{stock[:product_id]}""#{color_id}""#{size_id}" 
              sku = row["Sku"].present? ? row["Sku"].strip : format('%010d', _sku) 
            elsif AppConfiguration.get_config_value('sku_algorithm') == 'enabled'
              sku = ''
              sku = "#{sku}""#{AppConfiguration.get_config('sku_prefix_limit')}" if AppConfiguration.get_config_value('sku_prefix') == 'enabled' 
              sku = "#{sku}#{stock.p_gender}#{stock.product.category.code}#{stock.product.brand_code}" if AppConfiguration.get_config_value('category_code') == 'enabled'
              sku = "#{sku}#{stock.stock_transaction.purchase_order.vendor.code}" if AppConfiguration.get_config_value('vendor_code') == 'enabled'
              sku = "#{sku}#{stock.color.code}" if AppConfiguration.get_config_value('color_code') == 'enabled' and stock.color.present?
              sku = "#{sku}#{stock.size.code}" if AppConfiguration.get_config_value('size_code') == 'enabled' and stock.size.present?
              sku = "#{sku}#{stock.product.p_code}" if AppConfiguration.get_config_value('product_serial') == 'enabled'
            else
              sku = row["Sku"].present? ? row["Sku"].strip : format('%010d', stock.id)
            end  
            stock.update_column(:sku, sku)
            StockPrice.add_stock_price(stock.id, row["Landing Price per unit"], row["MRP"], stock[:product_id], total_price_without_tax.to_f, total_tax, stock_additional_cost, total_price_with_tax, "",stock_discount,nil,row["Sell price with tax"])
            if AppConfiguration.get_config_value('retail_menu') == 'enabled' 
              if UnitProduct.by_unit(unit_id).by_product(stock[:product_id]).present?
                up = UnitProduct.by_unit(unit_id).by_product(stock[:product_id]).first
                _total_amnt = 0
                i = 1
                @tax_array = up.tax_group.tax_classes
                @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
                @tax_array.each do |tc|
                  if tc.tax_type == 'variable'
                    if row["Sell price with tax"].to_f <= _limit_vtax
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
                sell_price_without_tax = (row["Sell price with tax"].to_f * 100)/(_total_amnt.to_f + 100)
                if AppConfiguration.get_config_value('uniqe_stock_for_color_size') == 'enabled'
                  # lot = Lot.find_by_menu_product_id_and_sku(mp.id,stock[:sku])
                  if stock[:batch_no].present?
                    lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(stock[:product_id],stock[:sku],stock[:expiry_date],sell_price_without_tax,stock[:batch_no],0,stock.store_id)
                  else
                    lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(stock[:product_id],stock[:sku],stock[:expiry_date],sell_price_without_tax,0,stock.store_id)
                  end  
                  if lot.present? && lot.mode == 0
                    stock_qty = lot.stock_qty + stock[:available_stock]
                    lot.update_attributes(:stock_qty => stock_qty)
                  else
                    Lot.save_lot(nil,0,sell_price_without_tax,stock[:sku],stock[:stock_credit],stock[:product_id],stock[:expiry_date],stock.id,row["Procured Price"],row["MRP"],nil,stock[:color_name],stock[:size_name],stock[:size_id],stock[:color_id],row["Description"],stock.batch_no,stock[:sell_price_with_tax],store_id,up.id)
                  end 
                else
                  if stock[:batch_no].present?
                    lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_batch_no_and_mode_and_store_id(stock[:product_id],stock[:sku],stock[:expiry_date],sell_price_without_tax,stock[:batch_no],0,stock.store_id)
                  else
                    lot = Lot.find_by_product_id_and_sku_and_expiry_date_and_sell_price_without_tax_and_mode_and_store_id(stock[:product_id],stock[:sku],stock[:expiry_date],sell_price_without_tax,0,stock.store_id)
                  end  
                  if lot.present? && lot.mode == 0
                    stock_qty = lot.stock_qty + stock[:available_stock]
                    lot.update_attributes(:stock_qty => stock_qty)
                  else
                    Lot.save_lot(nil,0,sell_price_without_tax,stock[:sku],stock[:stock_credit],stock[:product_id],stock[:expiry_date],stock.id,row["Procured Price"],row["MRP"],nil,stock[:color_name],stock[:size_name],stock[:size_id],stock[:color_id],row["Description"],stock.batch_no,stock[:sell_price_with_tax],store_id,up.id)
                  end 
                end  
              end
            end
            # mentum = PurchaseOrderMetum.find_by_product_id_and_purchase_order_id(product.id,@stock_purchase.purchase_order.id)
            mentum = PurchaseOrderMetum.find_by_product_id_and_purchase_order_id_and_color_id_and_size_id(product.id,@stock_purchase.purchase_order.id,stock[:color_id],stock[:size_id])
            if mentum == nil
              metum = PurchaseOrderMetum.new
              metum[:product_amount] = stock[:stock_credit]
              metum[:product_id] = stock[:product_id]
              metum[:purchase_order_id] = @stock_purchase.purchase_order.id
              metum.vendor_price = row["Landing Price per unit"].present? ? row["Landing Price per unit"] : 0
              metum[:color_id] = stock[:color_id]
              metum[:size_id] = stock[:size_id]
              metum.save
            end
          end
        else
          stock_total_price = 0
          stock = Stock.new
          stock.attributes = row.to_hash.slice(*Stock.accessible_attributes)
          product = Product.find_by_id(row["Product"]) || Product.find_by_name(row["Product"])
          stock[:product_id] = product.id.present? ? product.id : nil
          stock[:store_id] = store_id.present? ? store_id : nil
          stock[:stock_transaction_id] = stock_transaction_id.present? ? stock_transaction_id : nil
          stock[:stock_transaction_type] = stock_transaction_type.present? ? stock_transaction_type : nil
          stock[:stock_debit] = 0
          stock[:expiry_date] = row["Expiry Date"].present? ? row["Expiry Date"] : nil
          stock[:available_stock] = row["Quantity"]
          stock[:stock_credit] = row["Quantity"]
          stock_discount = row["Discount"].present? ? row["Discount"] : 0
          stock_additional_cost = row["Additional Cost"].present? ? row["Additional Cost"] : 0
          stock_total_price = row["Landing Price per unit"].to_f * row["Quantity"].to_f + stock_additional_cost.to_f - stock_discount.to_f
          stock[:price] = stock_total_price.to_f
          stock[:sku] = row["Sku"].present? ? row["Sku"].strip : product.sku

          total_price_without_tax = row["Landing Price per unit"].to_f * row["Quantity"].to_f - stock_discount.to_f

          tax_on_mrp_pc = row["Tax(%) on MRP"].present? ? row["Tax(%) on MRP"] : 0
          tax_on_landing_pc = row["Tax(%) on Landing"].present? ? row["Tax(%) on Landing"] : 0
          total_tax = 0

          if !tax_on_mrp_pc.nil? || tax_on_mrp_pc != 0
            total_tax = row["MRP"].to_f * row["Quantity"].to_f * tax_on_mrp_pc.to_f / 100
          elsif !tax_on_landing_pc.nil? || tax_on_landing_pc != 0
            total_tax = row["Landing Price per unit"].to_f * row["Quantity"].to_f * tax_on_landing_pc.to_f / 100
          end

          total_price_with_tax = total_price_without_tax.to_f + total_tax.to_f + stock_additional_cost.to_f

          if stock.save
            product.update_attribute(:hsn_code, row["Hsn-code"])
            StockPrice.add_stock_price(stock.id, row["Landing Price per unit"], row["MRP"], stock[:product_id], total_price_without_tax.to_f, total_tax, stock_additional_cost, total_price_with_tax, "",stock_discount,nil,row["Sell price without tax"])
            mentum = PurchaseOrderMetum.find_by_product_id_and_purchase_order_id(product.id,@stock_purchase.purchase_order.id)
            if mentum == nil
              metum = PurchaseOrderMetum.new
              metum[:product_amount] = stock[:stock_credit]
              metum[:product_id] = stock[:product_id]
              metum[:purchase_order_id] = @stock_purchase.purchase_order.id
              metum.vendor_price = row["Landing Price per unit"].present? ? row["Landing Price per unit"] : 0
              metum.save
            end
          end
        end
      end
    end
    StockPurchase.update_purchase_status(@stock_purchase)
  end

  private

  # => Callback function to set model attributes before validation 
  def set_purchase_attributes
    _po_details = PurchaseOrder.find(self.purchase_order_id)
    _po_meta_product_id = self.purchase_order.purchase_order_metum
    _po_vendor_id = self.purchase_order.vendor_id
    _product_id_arr = []
    _product_price_arr = []
    _po_meta_product_id.each do |pro_id|
      _product_id_arr.push(pro_id.product_id) 
    end
    _po_pending_amount = VendorProduct.by_vendor_product_in(_product_id_arr).by_vendor(_po_vendor_id)
    
    _po_pending_amount.each do |por_price|
      _product_price_arr.push(por_price.price)
    end
    _total=0
    _product_price_arr.each do |sum|
      # _total += sum.to_i unless sum!= nil
      _total = _total + sum unless sum == nil
    end
    self.status = "1"
    self.payment_status = "unpaid"
    self.store_id = _po_details.store_id
    self.purchase_order_id = _po_details.id
    self.total_amount = _total
    #Generating status JSON
    _stat_log = Array.new
    _arr = {}
    _arr[:status_id] = "1"
    _arr[:status_short_desc] = "Purchase order has been sent to vendor"
    _arr[:time] = Time.now.strftime("%d-%m-%Y %H:%M")
    _stat_log.push(_arr)
    self.status_log = JSON.generate(_stat_log)
  end
end