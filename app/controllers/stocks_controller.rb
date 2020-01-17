class StocksController < ApplicationController
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  require 'barby'
  require 'barby/barcode/code_128'
  require 'barby/outputter/png_outputter'

  layout "material"

  before_filter :set_module_details

  # GET /stocks
  # GET /stocks.json
  def index
    begin
      @store = Store.find(params[:store_id])
      @product = Product.find(params[:product_id])
      @stocks = @store.stocks.get_product(params[:product_id])
      #@lots = Lot.by_product(params[:product_id])
      @stock_scope = Stock.select("product_id, sum(price) as total_price,sum(available_stock) as total_available_stock,color_name,size_name,stock_identity,batch_no").group("product_id, color_name, size_name, stock_identity, batch_no").by_product(params[:product_id]).set_store_in(@store.id).available
      @stock_expiry_date = AppConfiguration.get_config_value('stock_expiry_date')
      smart_listing_create :audit_credits, @stocks.set_transaction_type('StockAudit').type_credit, partial: "stocks/cr_audit_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :purchase_credits, @stocks.set_transaction_type('StockPurchase').type_credit, partial: "stocks/cr_purchase_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :production_credits, @stocks.set_transaction_type('StockProduction').type_credit, partial: "stocks/cr_production_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :transfer_credits, @stocks.set_transaction_type('StockTransfer').type_credit, partial: "stocks/cr_transfer_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :simo_credits, @stocks.set_transaction_type('SimoInputProduct').type_credit, partial: "stocks/cr_simo_smartlist",default_sort:{created_at:"desc"}
      smart_listing_create :transfer_debits, @stocks.set_transaction_type('StockTransfer').type_debit, partial: "stocks/db_transfer_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :consumption_debits, @stocks.set_transaction_type('StockProduction').type_debit, partial: "stocks/db_consumption_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :audit_debits, @stocks.set_transaction_type('StockAudit').type_debit, partial: "stocks/db_audit_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :order_debits, @stocks.set_transaction_type_in(['Order','OrderDetail']).type_debit, partial: "stocks/db_order_smartlist",default_sort: {created_at: "desc"}
      smart_listing_create :simo_debits, @stocks.set_transaction_type('Simo').type_debit, partial: "stocks/db_simo_smartlist",default_sort:{created_at:"desc"}
      
      @site_title = AppConfiguration.get_config_value('site_title')
      @lots = Lot.by_product(params[:product_id]).active.by_store(params[:store_id])
      @lots = @lots.filter_by_sku(params[:sku_filter]) if params[:sku_filter].present?
      smart_listing_create :available_lots, @lots, partial: "stocks/available_lots_smartlist",default_sort:{created_at:"desc"}
      respond_to do |format|
        format.html # index.html.erb
        format.js
      end      
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(@store), notice: e.message.to_s
    end
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
    @stock = Stock.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock }
    end
  end

  def barcode
    @stock = Stock.find(params[:id])
    if @stock.sku.present?     
      _ean_barcode = Barby::Code128B.new(@stock.sku)
      # @ean_barcode = Barby::EAN13.new(@product.sku)
      @png_blob = Barby::PngOutputter.new(_ean_barcode).to_png(:margin => 2, :xdim => 2, :height => 25)
    end    
    respond_to do |format|
      format.png do
        send_data @png_blob, type: "image/png", disposition: "inline"
      end 
    end
  end

  def by_sku
    begin
      _stock = Stock.available.by_sku(params[:sku]).set_store(params[:store_id]).first # --- ******* Add store param verification here
      raise I18n.t(:error_invalid_sku, sku: params[:sku]) unless _stock.present?
      _data = {}
      if _stock.product.by_weight?
        @raw_unit_name = (ProductUnit.find(_stock.received_product_unit)).name 
        @raw_unit_id = _stock.received_product_unit
      elsif _stock.product.by_bulk_weight?
        @raw_unit_id = (_stock.product.product_compositions.first).raw_product_unit
        @raw_unit_name = (ProductUnit.find(@raw_unit_id)).short_name
      else
        @raw_unit_id = _stock.received_product_unit
        @raw_unit_name = nil
      end
      # _weight = _stock.product.by_bulk_weight? ? (_stock.weight.to_f / (ProductUnit.find((_stock.product.product_compositions.first).raw_product_unit)).multiplier.to_f) : _stock.weight
      # _weight = _stock.weight
      _menu_product = MenuProduct.active_menu_product(_stock.store_id,_stock.product_id)
      raise "Product doesn't belong to any catalog" unless _menu_product.present?
      _data[:sku] = _stock.sku
      _data[:current_stock] = _stock.available_stock
      _data[:weight] = _stock.weight
      _data[:product_unit] = @raw_unit_name
      _data[:product_unit_id] = @raw_unit_id
      _data[:making_cost] = _stock.making_cost
      _data[:sell_price] = _stock.sell_price_of_item
      _data[:product_type] = _stock.product.sell_type
      _data[:product] = _stock.product
      _data[:menu_product_id] = _menu_product.id
      _data[:description] = _stock.stock_defination.description
      respond_to do |format|
        format.json { render :json => { :error => false, :message => "Stock record found with SKU: #{params[:sku]}",:data=>_data }}
      end      
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render :json => { :error => true, :message => e.message.to_s,:data=>nil }}
      end       
    end
  end
  
  def edit
    
  end

  def barcode_print_update
    _stock = Stock.find(params[:stock_id])
    _stock.update_attribute(:is_barcode_printed,1)
    respond_to do |format|
      format.json { render json: _stock }
    end
  end

  private

  def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end
    
end
