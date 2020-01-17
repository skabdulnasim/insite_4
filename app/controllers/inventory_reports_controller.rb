class InventoryReportsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include ApplicationHelper
  include InventoryReportsHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:store_stocks, :stock_transfer, :stock_purchase, :stock_consumption, :store_indent, :stock_issue, :unit_wise_stock_transfer, :unit_wise_stock_purchase, :unit_wise_stock_purchase_summary, :unit_wise_stock_transfer_summary, :raw_product_consumption, :unit_wise_stock_summary, :vendor_wise_product_sale]

  def index
    @units = Unit.order("unit_name asc").all
    # @stores = current_user.unit.stores
    @stores = Store.all
    @vendors = Vendor.all
  end

  def store_stocks
    begin
      raise "Please select a store" unless params[:store_id].present?
      @store_id = params[:store_id]
      @store = Store.find(params[:store_id])
      @pro_scope = Product.get_all.order("name asc")
      @pro_scope = @pro_scope.filter_by_string(params[:product_filter]) if params[:product_filter]
      @pro_scope = @pro_scope.check_stock_status(@store.id,params[:stock_filter],current_user.unit_id) if params[:stock_filter]
      @pro_scope = @pro_scope.set_category(params[:category]) if params[:category]
      smart_listing_create :reports, @pro_scope, partial: "inventory_reports/store_stock_report_smartlist",default_sort: {name: "asc"}
      respond_to do |format|
        format.js
        format.html #
        format.pdf { render :layout => false }
        format.csv { send_data Product.stock_report_to_csv(@store.id,@pro_scope,@from_datetime,@to_datetime,currency,current_user.unit_id) }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      # redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_transfer
    begin
      raise "Please select a store" unless params[:store_id].present?
      @store_id = params[:store_id]
      @store = Store.find(@store_id).name
      @transfer_type = params[:transfer_type]
      @stocks = Stock.set_store(params[:store_id]).set_transaction_type('StockTransfer').check_stock_date(@from_datetime,@to_datetime)
      smart_listing_create :stock_transfers, @stocks.type_credit, partial: "inventory_reports/cr_transfer_smartlist" if params[:transfer_type] == "credit"
      smart_listing_create :stock_transfers, @stocks.type_debit, partial: "inventory_reports/db_transfer_smartlist" if params[:transfer_type] == "debit"
      respond_to do |format|
        format.js
        format.html #
        format.pdf { render :layout => false }
        format.csv { send_data Stock.stock_transfer(@stocks,@transfer_type) }        
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def pending_stock_receive
    begin
      raise "Please select transfer and receive store" unless params[:transfer_store_id].present? and params[:receive_store_id].present?
      @stock_transfers = StockTransfer.where("primary_store_id=? and secondary_store_id=?", params[:transfer_store_id], params[:receive_store_id]).by_date_range(params[:from_date], params[:to_date])
      smart_listing_create :po_transfer_and_receive, @stock_transfers, partial: "inventory_reports/po_transfer_and_receive"
      respond_to do |format|
        format.html
        format.pdf { render :layout => false }
        format.csv { send_data StockTransfer.po_transfer_and_receive_reports_to_csv(@stock_transfers, params[:transfer_store_id], params[:receive_store_id], params[:from_date], params[:to_date]) }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def raw_product_consumption
    begin
      raise "Please select a store" unless params[:store_id].present?
      @store = Store.find(params[:store_id])
      @raw_product_ids = ProductComposition.uniq.pluck(:raw_product_id)
      @product_details = Product.set_id_in(@raw_product_ids)
      
      smart_listing_create :product_consumptions, @product_details, partial: "inventory_reports/raw_product_consumption_smartlist",default_sort: {id: "asc"}
      respond_to do |format|
        format.js
        format.html #
        format.csv { send_data raw_product_consumption_to_csv(@product_details), filename: "raw-material-consumption-per-outlet-report-#{params[:from_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_consumption
    begin
      raise "Please select atleast one consumption type" if params[:stock_transaction_type].nil?
      raise "Please select atleast one store" if params[:consumption_store].nil?
      @stocks = Stock.select("product_id, sum(stock_debit) as total_debit").group("product_id").set_store_in(params[:consumption_store]).set_transaction_type_in(params[:stock_transaction_type]).check_stock_date(@from_datetime,@to_datetime).type_debit
      respond_to do |format|
        format.html #
        format.pdf { render :layout => false }
        format.csv { send_data Stock.consumption_to_csv(@stocks), filename: "stock-consumption-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_in_hand
    begin
      raise "Please select a branch" unless params['units_ids'].present? || params['units'].present?
      @unit_arr = eval(params['units']) if params['units'].present?
      @unit_arr = params['units_ids'] if params['units_ids'].present?
      @units = Unit.set_id_in(@unit_arr)
      @unit = @units.last
      @stores = Store.set_unit_in(@unit_arr).physical
      _pro_arr = Array.new
      _menu_products = MenuManagement::get_activated_menu_products(@unit.id)
      _menu_products.each do |mp|
        _pro_arr.push(mp.product_id)
      end
      @products = Product.set_id_in(_pro_arr).order("name asc")
      @products = @products.filter_by_string(params[:product_filter]) if params[:product_filter].present?
      @products = @products.set_category(params[:catrgory]) if params[:catrgory].present?
      smart_listing_create :reports, @products, partial: "inventory_reports/stock_in_hand_report_samrtlisting"
      respond_to do |format|
        format.html #
        format.js
        format.csv { send_data Stock.stock_in_hand_to_csv(@products,@stores,@from_datetime,@to_datetime), filename: "stock_in_hand-of-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end
  def vendor_products
    @vendor_products = VendorProduct.where("product_id=?",params[:product_id])
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data vendor_product_csv_report(@vendor_products) ,file_name: "Vendor-product-report#{Time.now.utc}.csv"}
    end
  end
  def vendor_payment
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @vendors = Vendor.by_unit(@unit_id)
    smart_listing_create :vendor_payment_reports,@vendors , partial: "inventory_reports/vendor_payment_report_smartlist"
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data vendor_payment_csv_report(@vendors) ,file_name: "Vendor-payment-report.csv"}
    end
  end
  def vendor_wise_product_sale
    begin
      raise "Please select a vendor." unless params[:vendor_id].present?
      @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
      @vendors = Vendor.by_unit(@unit_id)
      @vendor = Vendor.find(params[:vendor_id])
      @sp_ids = Array.new
      @vendor.purchase_orders.map { |po| po.stock_purchases.map { |sp| @sp_ids.push sp.id } }
      @stocks = Stock.set_transaction_type('StockPurchase').set_transaction_in(@sp_ids).select("product_id, sum(stock_credit) as total_credit").group("product_id").type_credit.check_stock_date(@from_datetime,@to_datetime).order("product_id asc")
      smart_listing_create :vendor_wise_products_sale, @stocks, partial: "inventory_reports/vendor_wise_products_smartlist"
      respond_to do |format|
        format.html #
        format.js
        # format.csv { send_data stock_thresh_hold_to_csv(@products,@stores), filename: "thresh_hold_report.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end
  
  
  def vendor_payment_csv_report(vendors)
    CSV.generate do |csv|
      head_array = Array.new
      head_array.push('Vendor Name')
      head_array.push('Vendor Phone')
      head_array.push('Total Amount')
      head_array.push('Paid Amount')
      head_array.push('Due Amount')
      csv << head_array

      vendors.each do |vendor|
        row_array = Array.new
        purchase_scope = StockPurchase.received.by_vendor(vendor.id).date_range(params[:from_date],params[:to_date])
        total_amount = 0
        paid_amount = 0
        purchase_scope.each do |sp|
          if sp.total_amount.present?
            total_amount += sp.total_amount
          end
          if sp.paid_amount.present?
            paid_amount += sp.paid_amount
          end 
        end
        row_array.push(vendor.name)
        row_array.push(vendor.phone)
        row_array.push(total_amount)
        row_array.push(paid_amount)
        row_array.push(total_amount.to_f - paid_amount.to_f)
        csv << row_array
        row_array.clear
      end  
    end
  end

  def stock_thresh_hold
    begin
      raise "Please select a store." unless params['thresh_hold_store'].present?
      @stores=Store.set_id_in(params['thresh_hold_store'])
      @products = Product.thresh_hold_product
      @products = @products.by_product_name_like(params[:filter]) if params[:filter].present?
      @products = @products.by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
      @products = @products.filter_by_product_category(params[:product_category]) if params[:product_category].present?
      smart_listing_create :thresh_hold_reports, @products, partial: "inventory_reports/thresh_hold_report_samrtlisting"
      respond_to do |format|
        format.html #
        format.js
        format.csv { send_data stock_thresh_hold_to_csv(@products,@stores), filename: "thresh_hold_report.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_thresh_hold_to_csv(products, stores)
    CSV.generate do |csv|
      _header = Array.new
      _header.push("Product")
      _header.push("Basic Unit")
      _header.push("Category")
      _header.push("Subcategory")
      _header.push("Store")
      _header.push("Thresh hold limit")
      _header.push("Current stock")
      csv << _header
      stores.each do |s|
        products.each do |p|
          _curr_stck = StockUpdate.current_stock(s.id, p.id).to_f
          product_array = Array.new
          product_array.push("#{p.name}")
          product_array.push("#{p.basic_unit}")
          product_array.push(p.category.parent.present? ? "#{Category.find(p.category.parent).name}" : "-")
          product_array.push("#{p.category.name}")
          product_array.push("#{s.name}")
          product_array.push("#{p.thresh_hold} #{p.basic_unit}")
          product_array.push("#{_curr_stck} #{p.basic_unit}")
          csv << product_array      
          product_array.clear
        end  
      end
    end
  end 
  
  def stock_aging_report
    products = Stock.select("product_id").uniq.includes(:product)
    smart_listing_create :stock_aging_report,products,partial:"inventory_reports/stock_aging_report_smart_list"
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data stock_aging_report_csv(products),filnename:"stock_aging_report#{Date.new}.csv"}
    end
  end

  def stock_in_store
   
      unit_ids = []
      @current_user.unit.children.map { |e| unit_ids.push e.id } if @current_user.unit.children.present?
      unit_ids << @current_user.unit.id
      @child_units = Unit.set_id_in(unit_ids)
      @unit_arr = eval(params['units']) if params['units'].present?
      @unit_arr = params['units_idss'] if params['units_idss'].present?
      @units = Unit.set_id_in(@unit_arr)
      @unit = @units.last
      @stores = Store.set_unit_in(@unit_arr).not_return.primary_secondery
      @products = Product.order("name asc")
      @products = @products.filter_by_string(params[:product_filter]) if params[:product_filter].present?
      @products = @products.check_product_stock_status(params[:stock_filter],@unit.id,@current_user) if params[:stock_filter]
      @products = @products.set_category(params[:catrgory]) if params[:catrgory].present?
      smart_listing_create :reports, @products, partial: "inventory_reports/stock_in_store_hand_report_samrtlisting"
      respond_to do |format|
        format.html #
        format.js
        format.csv { send_data stock_in_store_hand_to_csv(@products,@stores), filename: "stock_in_store_hand.csv" }
      end
    
  end

  def store_indent
    begin
      raise "Please select a store" unless params[:store_id].present?
      @stores = current_user.unit.stores
      @store = Store.find(params[:store_id])
      @requisition_scope = @store.store_requisition_logs.by_date(@from_datetime,@to_datetime)
      smart_listing_create :reports, @requisition_scope, partial: "inventory_reports/store_indent_report_smartlist",default_sort: {created_at: "desc"}
      respond_to do |format|
        format.html #
        format.js
        format.pdf { render :layout => false }
        format.csv { send_data StoreRequisitionLog.to_csv(@requisition_scope), filename: "indent-report-of-#{@store.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_movement
    @products = ProductComposition.uniq.pluck(:raw_product_id)
    @product_details = Product.set_id_in(@products)
  end
  
  def stock_audit
    begin
      raise "Please select a store" unless params[:store_id].present?
      @stores = current_user.unit.stores
      @store = Store.find(params[:store_id])
      @stock_audits = @store.stock_audits.approved_audit.by_date(@from_datetime,@to_datetime)
      smart_listing_create :reports, @stock_audits, partial: "inventory_reports/stock_audit_report_smartlisting",default_sort: {created_at: "desc"}
      respond_to do |format|
        format.html #
        format.js
        format.csv { send_data stock_audit_to_csv(@stock_audits), filename: "stock-audit-report-of-#{@store.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      # redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_issue
    begin
      raise "Please select a store" unless params[:store_id].present?
      @stores = current_user.unit.stores
      @store = Store.find(params[:store_id])
      @stock_issue_scope = @store.stock_debit_transfers.by_date(@from_datetime,@to_datetime)
      smart_listing_create :reports, @stock_issue_scope, partial: "inventory_reports/stock_issue_report_smartlist",default_sort: {created_at: "desc"}
      respond_to do |format|
        format.html #
        format.js
        format.pdf { render :layout => false }
        format.csv { send_data StockTransfer.to_csv(@stock_issue_scope), filename: "Stock-issue-report-of-#{@store.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

   def unit_wise_stock_transfer
    begin
      raise "Please select a branch" unless params['unit_ids'].present? || params['units'].present? 
      @unit_arr = params['unit_ids'] if params['unit_ids'].present? ? params['unit_ids'] : current_user.unit_id
      @unit_arr = eval(params['units']) if params['units'].present?
      @stores = Store.set_unit_in(@unit_arr).order("unit_id")
      if params[:product_filter] 
        @product_id = Product.filter_by_string(params[:product_filter]) 
        @stocks_transfer = Stock.set_store_in(@stores).set_transaction_type('StockTransfer').type_debit.check_stock_date(@from_datetime,@to_datetime).get_product_in(@product_id).ordered            
        @product_details = Stock.select("product_id, sum(price) as total_price,sum(stock_debit) as total_debit").group("product_id").get_product_in(@product_id).set_store_in(@stores).set_transaction_type('StockTransfer').type_debit.check_stock_date(@from_datetime,@to_datetime).order("product_id asc")
      else
        @stocks_transfer = Stock.set_store_in(@stores).set_transaction_type('StockTransfer').type_debit.check_stock_date(@from_datetime,@to_datetime).ordered
        @product_details = Stock.select("product_id, sum(price) as total_price,sum(stock_debit) as total_debit").group("product_id").set_store_in(@stores).set_transaction_type('StockTransfer').type_debit.check_stock_date(@from_datetime,@to_datetime).order("product_id asc")
      end
      smart_listing_create :unit_stock_transfers, @stocks_transfer, partial: "inventory_reports/unit_stock_transfer_smartlist"
      respond_to do |format|
        format.js
        format.html
        format.pdf { render :layout => false }
        format.csv { send_data Stock.unit_wise_stock_transfer_to_csv(@stocks_transfer,@product_details), filename: "unit_stocks_transfer-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }        
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def stock_purchase
    begin
      raise "Please select a store" unless params[:store_id].present?
      @stores = Store.set_id_in(params[:store_id])
      #@vendors = @store.unit.vendors.order("name asc")
      if params[:vendor_name_filter].present?
        _po_ids = PurchaseOrder.vendor_name_like(params[:vendor_name_filter]).pluck(:id)
        _sp_ids = StockPurchase.set_po_ids_in(_po_ids).pluck(:id)
      end
      store_ids = @stores.pluck(:id)
      @stocks = Stock.set_store_in(store_ids).set_transaction_type('StockPurchase').type_credit.check_stock_date(@from_datetime,@to_datetime)
      @stocks = @stocks.set_transaction_in(_sp_ids) if params[:vendor_name_filter].present?
      _tran_ids = @stocks.pluck(:stock_transaction_id)
      @purchase_scope = StockPurchase.set_ids_in(_tran_ids)
      smart_listing_create :reports, @purchase_scope, partial: "inventory_reports/stock_purchase_report_smartlist",default_sort: {id: "asc"}
      respond_to do |format|
        format.js
        format.html #
        format.pdf { render :layout => false }
        format.csv { send_data StockPurchase.to_csv(@purchase_scope), filename: "stock-purchase-report-#{params[:from_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      # redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def unit_wise_stock_purchase
    begin
      raise "Please select a branch" unless params['unit_ids'].present? || params['units'].present? 
      @unit_arr = params['unit_ids'] if params['unit_ids'].present? ? params['unit_ids'] : current_user.unit_id
      @unit_arr = eval(params['units']) if params['units'].present?
      @stores = Store.set_unit_in(@unit_arr).order("unit_id")
      _store_ids = @stores.pluck(:id)
      # if params[:vendor_id].present?
      #   _po_ids = PurchaseOrder.by_vendor(params[:vendor_id]).pluck(:id)
      #   _sp_ids = StockPurchase.set_po_ids_in(_po_ids).pluck(:id)
      # end
      if params[:vendor_name_filter].present?
        _po_ids = PurchaseOrder.vendor_name_like(params[:vendor_name_filter]).pluck(:id)
        _sp_ids = StockPurchase.set_po_ids_in(_po_ids).pluck(:id)
      end
      if params[:product_filter] 
        @product_id = Product.filter_by_string(params[:product_filter]).pluck(:id)

        @stocks_purchase = Stock.set_store_in(_store_ids).set_transaction_type('StockPurchase').type_credit.check_stock_date(@from_datetime,@to_datetime).get_product_in(@product_id).ordered            
        @product_details = Stock.select("product_id, sum(price) as total_price,sum(stock_credit) as total_credit").group("product_id").get_product_in(@product_id).set_store_in(_store_ids).set_transaction_type('StockPurchase').type_credit.check_stock_date(@from_datetime,@to_datetime).order("product_id asc")
        @stocks_purchase = @stocks_purchase.set_transaction_in(_sp_ids) if params[:vendor_name_filter].present?
        @product_details = @product_details.set_transaction_in(_sp_ids) if params[:vendor_name_filter].present?
      else
        @stocks_purchase = Stock.set_store_in(_store_ids).set_transaction_type('StockPurchase').type_credit.check_stock_date(@from_datetime,@to_datetime)
        @product_details = Stock.select("product_id, sum(price) as total_price,sum(stock_credit) as total_credit").group("product_id").set_store_in(_store_ids).set_transaction_type('StockPurchase').type_credit.check_stock_date(@from_datetime,@to_datetime).order("product_id asc")
        @stocks_purchase = @stocks_purchase.set_transaction_in(_sp_ids) if params[:vendor_name_filter].present?
        @product_details = @product_details.set_transaction_in(_sp_ids) if params[:vendor_name_filter].present?
      end
      smart_listing_create :unit_stock_purchase, @stocks_purchase, partial: "inventory_reports/unit_stock_purchase_smartlist"
      respond_to do |format|
        format.js
        format.html
        format.pdf { render :layout => false }
        format.csv { send_data Stock.unit_wise_stock_purchase_to_csv(@stocks_purchase,@product_details), filename: "unit-stocks-purchase-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }        
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      # redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def unit_wise_stock_purchase_summary
    begin
      raise "Please select a branch" unless params['unit_ids'].present? || params['units'].present?
      @all_unit = Unit.order("unit_name asc").all
      if params["unit_ids"].present?
        @unit_arr = params['unit_ids']
      else
        @unit_arr = eval(params['units'])
      end 
      @stores = Store.set_unit_in(@unit_arr)
      _store_ids = @stores.pluck(:id)
      @puchase_stock = Stock.set_store_in(_store_ids).select("store_id, sum(price) as total_price,sum(stock_credit) as total_credit").group("store_id").set_transaction_type('StockPurchase').type_credit.check_stock_date(@from_datetime,@to_datetime)
      smart_listing_create :unit_stock_purchase_summery, @puchase_stock, partial: "inventory_reports/unit_stock_purchase_summery_smartlist"  
      respond_to do |format|
        format.js
        format.html
        format.pdf { render :layout => false }
        format.csv { send_data Stock.unit_wise_stock_purchase_summary_to_csv(@puchase_stock), filename: "unit-stocks-purchase-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }        
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def unit_wise_stock_transfer_summary
    begin
      raise "Please select a branch" unless params['unit_ids'].present? || params['units'].present?
      @all_unit = Unit.order("unit_name asc").all
      if params["unit_ids"].present?
        @unit_arr = params['unit_ids']
      else
        @unit_arr = eval(params['units'])
      end  
      @stores = Store.set_unit_in(@unit_arr)
      @stock_transfer_summary = Stock.select("store_id, sum(price) as total_price").group("store_id").set_store_in(@stores).set_transaction_type('StockTransfer').type_debit.check_stock_date(@from_datetime,@to_datetime)
      smart_listing_create :unit_stock_transfer_summery, @stock_transfer_summary, partial: "inventory_reports/unit_stock_transfer_summery_smartlist"  
      respond_to do |format|
        format.js
        format.html
        format.pdf { render :layout => false }
        format.csv { send_data Stock.unit_wise_stock_transfer_summary_to_csv(@stock_transfer_summary), filename: "unit-stocks-transfer-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }        
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def avaliable_stock
    begin
      raise "Please select a store" unless params[:store_id].present?
      _category_id = Product.uniq.pluck(:category_id)
      @categories = Category.by_category_ids(_category_id)
      @store = Store.find(params[:store_id])
      if params[:category_id].present?
        @stocks = Stock.includes([:stock_defination],[:product]).available.set_store(params[:store_id]).order("products.category_id").by_category_id(params[:category_id])
      else
        @stocks = Stock.includes([:stock_defination],[:product]).available.set_store(params[:store_id]).order("products.category_id")
      end
      smart_listing_create :avaliable_reports, @stocks, partial: "inventory_reports/avaliable_stock_report_smartlist"
      respond_to do |format|
        format.html #
        format.js
        format.csv { send_data Stock.avaliable_stock_to_csv(@stocks), filename: "Stock-avaliable-report-of-#{@store.name}-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def avaliable_stock_for_period
    begin
      raise "Please select a store" unless params[:store_id].present?
      _category_id = Product.uniq.pluck(:category_id)
      @to_datetime = params[:to_date]
      @categories = Category.find(_category_id).sort
      @store = Store.find(params[:store_id])
      if params[:category_id].present?
        @stocks = Stock.select("SKU, sum(stock_credit) as total_credit, product_id").group("sku,product_id").set_store(params[:store_id]).type_credit.check_date(@to_datetime).by_category_id(params[:category_id])
      else
        @stocks = Stock.select("SKU, sum(stock_credit) as total_credit, product_id").group("sku,product_id").set_store(params[:store_id]).type_credit.check_date(@to_datetime)
      end  
      smart_listing_create :avaliable_reports_for_period, @stocks, partial: "inventory_reports/avaliable_stock_report_for_period_smartlist"
      respond_to do |format|
        format.html #
        format.js
        format.csv { send_data Stock.avaliable_stock_of_period_to_csv(@stocks,@store,@to_datetime), filename: "Avaliable-stock-report-of-period-#{@store.name}-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def save_report_preferences
    _preference = ReportPreference.by_unit(current_user.unit_id).by_key(params[:report_key]).first
    _attributes =  JSON.generate(params[:columns])
    if _preference.present?
      _preference.update_attributes(:allowed_attributes => _attributes)
    else
      ReportPreference.create(:report_key => params[:report_key], :allowed_attributes => _attributes, :unit_id => current_user.unit_id)
    end
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Preferences successfully updated.' }
    end    
  end

  def cost_of_material_report
    puts params[:store_id]
    @stocks = Stock.by_date_range(params[:from_date],params[:to_date]).type_debit.where("store_id=?",params[:store_id]).select("product_id,sum(stock_debit) as stock_debit,sum(price) as cost").group(:product_id)
    smart_listing_create :cost_of_material_reports,@stocks , partial: "inventory_reports/cost_of_material_reports_smartlist"
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data Stock.cost_of_material_csv_report(@stocks) ,file_name: "CostOfMaterial-summary-report.csv"}
    end
  end

  def stock_expiry_report
    @stock_expires = Stock.by_expiry_date_range(params[:from_date],params[:to_date]).type_credit.set_store(params[:store_id])
    smart_listing_create :stock_expiry_reports,@stock_expires , partial: "inventory_reports/stock_expiry_report_smartlist"
    respond_to do |format|
      format.html
      format.js
      format.csv{send_data Stock.stock_expiry_csv_report(@stock_expires) ,file_name: "Stock-expiry-report.csv"}
    end
  end

  # def unit_wise_stock_summary
  #   begin
  #     raise "Please select a branch" unless params['unit_ids'].present? || params['units'].present?
  #     @all_unit = Unit.order("unit_name asc").all
  #     if params["unit_ids"].present?
  #       @unit_arr = params['unit_ids']
  #     else
  #       @unit_arr = eval(params['units'])
  #     end  
  #     @stores = Store.set_unit_in(@unit_arr).order('unit_id')
  #     smart_listing_create :unit_wise_stock_summary, @stores, partial: "inventory_reports/unit_wise_stock_summary_smartlist"
  #     respond_to do |format|
  #       format.js
  #       format.html
  #       # format.pdf { render :layout => false }
  #       # format.csv { send_data Stock.unit_wise_stock_transfer_summary_to_csv(@stock_transfer_summary), filename: "unit-stocks-transfer-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }        
  #     end  
  #   rescue Exception => e
  #     Rscratch::Exception.log e,request
  #     redirect_to inventory_reports_path, alert: e.message.to_s
  #   end
  # end

  def unit_wise_stock_summary
    begin
      raise "Please select a branch" unless params['unit_ids'].present? || params['units'].present?
      @all_unit = Unit.order("unit_name asc").all
      if params["unit_ids"].present?
        @unit_arr = params['unit_ids']
      else
        @unit_arr = eval(params['units'])
      end  
      @f_date = params[:from_date]
      @t_date = params[:to_date]
      @units = Unit.set_id_in(@unit_arr)
      @pro_scope = Product.get_all.order("name asc")
      smart_listing_create :unit_wise_stock_summary, @units, partial: "inventory_reports/unit_wise_stock_summary_smartlist"
      respond_to do |format|
        format.js
        format.html
        # format.pdf { render :layout => false }
        # format.csv { send_data Stock.unit_wise_stock_transfer_summary_to_csv(@stock_transfer_summary), filename: "unit-stocks-transfer-summary-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }        
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  def store_simo_report
    begin
      raise "Please select a store" unless params[:store_id].present?
      @store_id = params[:store_id]
      @store = Store.find(params[:store_id])
      @simos = @store.simos.by_date_range(params[:from_date],params[:to_date])
      smart_listing_create :store_simos, @simos, partial: "inventory_reports/store_simo_report_smartlist",default_sort: {created_at: "asc"}
      respond_to do |format|
        format.js
        format.html #
        format.pdf { render :layout => false }
        format.csv { send_data store_simo_report_to_csv(@simos), filename: "store-simo-report-#{params[:from_date]}-#{params[:to_date]}.csv" }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to inventory_reports_path, alert: e.message.to_s
    end
  end

  private

  def set_module_details
    @module_id = "reports"
    @module_title = "Inventory Report"
  end

  def stock_in_store_hand_to_csv(products, stores)
    CSV.generate do |csv|
      store_array = Array.new
      product_array = Array.new
      stock_array = Array.new
      store_array.push('','')
      product_array.push('Products')
      product_array.push('Basic Unit')
      product_array.push('Total Stock')
      stores.each do |store|
        store_array.push(store.name)
        product_array.push("Current Stock")
      end  
      csv << store_array
      csv << product_array
      products.each do |product|
        stock_array.push(product.name)
        stock_array.push(product.basic_unit)
        stock_array.push("#{get_product_total_staock(product.id).pro_total_stock.to_f}"" #{product.basic_unit}")
        stores.each do |store|
          stock_array.push("#{get_store_product_data(product.id,store.id)}"" (#{product.basic_unit})")
        end
        csv << stock_array
        stock_array.clear
      end  
    end
  end 

  def raw_product_consumption_to_csv(product_details)
    CSV.generate do |csv|
      csv << ["Raw Product", "Opening Stock","Credit", "Total Stock", "Debit","Closing Stock","Menu Products","Total sale quantity","Total consumption"]
      product_details.each do |object|
        raw_products_row = Array.new
        _current_stocks = Stock.get_product_consumption_stock_report(@store.id,object.id,@from_datetime,@to_datetime)
        _product_name = "# " + object.id.to_s + " " + object.name + " (" + object.basic_unit + ")"
        raw_products_row.push(_product_name)
        raw_products_row.push(_current_stocks[:opening_stock].round(2))
        raw_products_row.push(_current_stocks[:total_credit].round(2))
        raw_products_row.push(_current_stocks[:opening_stock].round(2) + _current_stocks[:total_credit].round(2))
        raw_products_row.push(_current_stocks[:total_debit].round(2))
        raw_products_row.push(_current_stocks[:closing_stock].round(2))
        raw_products_row.push('')
        raw_products_row.push('')
        raw_products_row.push('')
        csv << raw_products_row

        _menu_products = ProductComposition.set_raw_product(object.id)
        _menu_products.each do |menu_product|
          _inventory_quantity = menu_product.inventory_quantity
          _order_details = OrderDetail.select("sum(quantity) as total_sale_quantity").by_date_range(@from_datetime,@to_datetime).by_product(menu_product.product_id).valid_item.set_unit(@store.unit_id)

          _total_sale_quantity = _order_details[0][:total_sale_quantity].present? ?  _order_details[0][:total_sale_quantity].to_f : 0

          menu_products_row = Array.new
          menu_products_row.push('')
          menu_products_row.push('')
          menu_products_row.push('')
          menu_products_row.push('')
          menu_products_row.push('')
          menu_products_row.push('')
          menu_products_row.push(menu_product.product.name)
          menu_products_row.push(_total_sale_quantity.round(2).to_s + "(" + menu_product.product.basic_unit + ")")
          menu_products_row.push((_total_sale_quantity * _inventory_quantity).round(2).to_s + " (" + object.basic_unit + ")")
        
          csv << menu_products_row
        end
      end
    end
  end

  def vendor_product_csv_report(vendor_products)
    CSV.generate do |csv|
      csv<<["Sl No","product name","vendor name" ,"price"] 
      i=0
      vendor_products.each do |vp|
        csv << [i=i+1,vp.product.name,vp.vendor.name,vp.price]
      end
    end
  end

  def store_simo_report_to_csv(simos)
    CSV.generate do |csv|
      csv << ['Simo Id','Simo Status','Stock Added','Input Product','Input Quantity','Input Price','Input Wastage','Output Products','Expected Quantity','Actual Quantity','Output Price','Total Weight']
      simos.each do |object|
        is_stock_added = object.isStockAdded == 1 ? 'Yes' : 'No'
        simo_input = object.simo_input_product
        csv << [object.id,object.status,is_stock_added,simo_input.product.name,"#{simo_input.quantity} #{simo_input.product.conjugated_unit}",simo_input.price,simo_input.wastage,'','','','','']
        simo_outputs = simo_input.simo_output_products
        simo_outputs.each do |simo_output_product|
          csv << ['','','','','','','',simo_output_product.product.name,"#{simo_output_product.expected_quantity} #{simo_output_product.product.basic_unit}","#{simo_output_product.actual_quantity} #{simo_output_product.product.basic_unit}",simo_output_product.price,simo_output_product.total_weight]
        end
      end
    end
  end
  
  def stock_audit_to_csv(stocks)
    CSV.generate do |csv|
     csv << ["Product", "Stock Consumed","product_Unit", "Audit Done By", "Remarks", "Delta stock","product_unit", "Delta stock price","Currency", "Date"]
      stocks.each do |object|
        object.stock_audit_metas.each do |meta|
         user = User.find(object.audit_done_by)
         audit_done_by = "#{user.profile.firstname.humanize} #{user.profile.lastname.humanize}" if user.present? and user.profile.present?
         audit_done_by ||= "#{user.email}" if user.present?
         audit_done_by ||=""
         stock_consumed,product_unit = meta.stock_consumed.present? ? ["#{meta.stock_consumed}",meta.product.basic_unit] : ["-","-"]
         delta_stock = meta.delta_stock.present? ? "#{meta.delta_stock}" : '-' 
         delta_stock_price = meta.delta_stock.to_f * Stock.current_stock_cost(object.store_id, meta.product.id).current_price.to_f
         remarks = meta.remarks.present? ? meta.remarks : '-'
         csv << ["#{meta.product.name}",stock_consumed,product_unit, "#{audit_done_by}", "#{remarks}", "#{delta_stock}",meta.product.basic_unit, "#{delta_stock_price}","#{currency}", "#{meta.created_at.strftime('%d-%^b-%Y, %I:%M %p')}"]
        end
      end
    end
  end
end