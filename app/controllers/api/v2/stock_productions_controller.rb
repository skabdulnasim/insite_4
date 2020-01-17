module Api
  module V2
    class StockProductionsController < ApplicationController

      ### => API Documentation (APIPIE) for 'get_products' action
      api :GET, '/api/v2/stock_productions/get_products', "List of all menu products and its ingredients for stock production."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Menu products of this unit"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :store_id, String, :required => true, :desc => "ID of the store."
      param :product_id, String, :required => true, :desc => "Filter by this product"
      ### => 'get_products' API Defination
      def get_products
        ActiveRecord::Base.transaction do
          @store_id = params[:store_id]
          _unit_id = params[:unit_id]
          _per = params[:count] || 20
          _pro_arr = Array.new
          if params[:product_id].present?
            _pro_arr.push(params[:product_id])
          else
            _menu_products = MenuManagement::get_activated_menu_products(_unit_id)
            _menu_products.each do |mp|
              _pro_arr.push(mp.product_id)
            end
          end  
          @menu_products = Product.set_id_in(_pro_arr).order("name asc")
          @menu_product_count = @menu_products.count
          @menu_products = @menu_products.page(params[:page]).per(_per) if params[:page].present?
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/stock_productions/', "Create stock production."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store_id, String, :required => true, :desc => "ID of the store."
      param :stock_production, Hash, :required => true, :desc => <<-EOS
        ==== A sample parameter value is given below
        {
          "stock_production" : {
            "kitchen_store_id" : "18",
            "status" : "1"
          },
          "menu_products" : [
            {
              "product_id" : "1",
              "quantity" : "1"
            },
            {
              "product_id" : "297",
              "quantity" : "1"
            }
          ]
        }
      EOS
      formats ['json']
      def create
        ActiveRecord::Base.transaction do
          puts params
          @store = Store.find(params[:store_id])
          _new_production = StockProduction.new(params[:stock_production][:stock_production])
          @store.stock_productions << _new_production

          @stock_production = _new_production

          @product_raws = {}
          params[:stock_production][:menu_products].each do |mp|
            _price,_ingr = consume_menu_product_raws(mp[:product_id],@store.id,mp[:quantity].to_f,@product_raws)
            _meta_entry = StockProductionMeta.new(:product_id=>mp[:product_id],:ingredients=>_ingr, :production_quantity=> mp[:quantity].to_f, :price=> _price, :store_id=>@store.id)
            _new_production.stock_production_metas << _meta_entry
          end

          @product_raws.each do |sp|
            _raw_stock = StockUpdate.current_stock(@store.id,sp[1][:product_id])
            raise "Error! #{sp[1][:product_id]} product do not have sufficient stock for production" if _raw_stock < sp[1][:production_qty]
            Stock.save_stock(sp[1][:product_id],@store.id,0,0,_new_production.id,'stock_production',0,sp[1][:production_qty],nil,nil,nil)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/stock_productions/:id', "Show stock production details."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :id, String, :required => true, :desc => "ID of the stock production to show the details."

      def show
        ActiveRecord::Base.transaction do
          @stock_production = StockProduction.find(params[:id])
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

      def consume_menu_product_raws(_mpro_id,_store_id,_mp_qty,_product_arry)
        #Building the raw product array
        _production_raws = Array.new
        _raw_price = 0
        _mp_sub_pros = ProductComposition::get_sub_products(_mpro_id)
        _mp_sub_pros.each do |mk|
          _raw_pro_id = mk['raw_product_id']
          _pro_unit_multiplier = (ProductUnit.find(mk['raw_product_unit'])).multiplier
          _total_raw_qty = (_pro_unit_multiplier.to_f)*(mk['raw_product_quantity'].to_f)*(_mp_qty.to_f) 
          if _product_arry && _product_arry.has_key?(_raw_pro_id)  
             _product_arry[_raw_pro_id][:production_qty] = ((_product_arry[_raw_pro_id][:production_qty]).to_f + _total_raw_qty)   
          else
            _raw_arr = {:product_id=>_raw_pro_id,:production_qty=>_total_raw_qty}
            _product_arry[_raw_pro_id] = _raw_arr              
          end  
          #Consuming the stock for this raw item
          _price = Stock.consumption_with_automated_debit(_store_id,_raw_pro_id,_total_raw_qty,'Production Center Consumption')
          _raw_price = _raw_price + _price
          _raw_arr = {:raw_product_id => _raw_pro_id, :raw_product_quantity=> _total_raw_qty}
          _production_raws.push(_raw_arr)
        end
        _production_raws_json = JSON.generate(_production_raws)
        return [_raw_price,_production_raws_json]
      end

    end
  end
end
