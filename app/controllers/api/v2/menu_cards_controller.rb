module Api
  module V2
    class MenuCardsController < ApplicationController      

      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/menu_cards/:id', "API to fetch a menu card."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :category_id, String, :required => false, :desc => "You can filter products by catalog category ID"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      param :image_size, String, :required => false, :desc => "which size you want to build ypur app", :meta => {:allowed_size => ["thumb","medium","original"], :example => "image_size=thumb"}
      param :filter, String, :required => false, :desc => "You can filter products by product name and product brand name"
      param :customer_id, String, :required => false, :desc => "If you want to know product exists in customer wishlist or not"
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with this resource will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["categories","products","stocks","lots","product_images"], :example => "resources=categories"}
      formats ['json']

      ### => 'show' API Defination      
      def show
        _per = params[:count] || 20
        @menu_card = MenuCard.find(params[:id])
        @category = MenuCategory.find(params[:category_id]) if params[:category_id].present?

        if @category.present?
          if @category.submenucategories.present?
            subcategory_ids = []
            @category.submenucategories.map { |e| subcategory_ids.push e.id }
            @menu_products = @menu_card.menu_products_variable_nil if @menu_card.present?
            @menu_products = @menu_products.set_sub_category_ids(subcategory_ids) if subcategory_ids.present?
            # @menu_products = @menu_products.filter_by_string(params[:filter]) if params[:filter].present?
          else
            @menu_products = @category.menu_products_variable_nil if @menu_card.present?
            # @menu_products = @menu_products.filter_by_string(params[:filter]) if params[:filter].present?
          end
        else
          @menu_products = @menu_card.menu_products_variable_nil if @menu_card.present?
          # @menu_products = @menu_products.filter_by_string(params[:filter]) if params[:filter].present?
        end
        @menu_products = @menu_products.filter_by_name_and_brand_name(params[:filter]) if params[:filter].present?
        @menu_product_count = @menu_products.count
        @menu_products = @menu_products.page(params[:page]).per(_per) if params[:page].present?
        @resources = params[:resources].present? ? params[:resources].split(',') : ['categories','products']
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'download menu card' action
      api :GET, '/api/v2/menu_cards/download_menu_cards', "Menu card download."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :menu_card_id, String, :required => true, :desc => "Id of menucard from which menu you want stock"
      def download_menu_cards
        @menu_card = MenuCard.find(params[:menu_card_id])
        @file_array = Array.new()
        directory_name = Rails.root.join('public', 'menu_cards')
        Dir.mkdir(directory_name) unless File.exists?(directory_name)
        @menu_products = ActiveRecord::Base.connection_pool.with_connection { |con| con.exec_query( "SELECT  menu_products.id AS id,
            menu_products.menu_category_id AS menu_category_id,
            menu_products.product_id AS product_id,
            menu_products.mode AS mode,
            menu_products.sell_price AS sell_price,
            menu_products.sell_price_without_tax AS sell_price_without_tax, 
            menu_products.sort_id AS sort_id, 
            menu_products.store_id AS store_id, 
            menu_products.is_buffet_product AS is_buffet_product,
            menu_products.isdefault AS isdefault,
            menu_products.stock_status AS stock_status,
            menu_products.variable_id AS variable_id,
            menu_products.combo_id AS combo_id,
            menu_products.tax_group_id AS tax_group_id,
            menu_products.procured_price AS procured_price,
            menu_products.sell_price AS mrp,
            menu_categories.name AS menu_category_name,
            menu_products.bill_destination_id AS bill_destination_id,
            tax_groups.name AS tax_group_name,
            tax_groups.total_amnt AS tax_group_amount,
            products.name AS product_name,
            products.product_type AS product_type,
            products.callorie AS product_callorie,
            sorts.name AS sort_name,
            products.local_name AS local_name,
            products.hsn_code AS product_hsn_code,
            product_basic_units.short_name AS product_basic_unit,
            product_attribute_values.value AS product_description
            
          FROM menu_products
          INNER JOIN products ON products.id=menu_products.product_id AND menu_products.menu_card_id=#{params[:menu_card_id]}
          INNER JOIN product_basic_units ON product_basic_units.id=products.basic_unit_id
          INNER JOIN tax_groups ON tax_groups.id=menu_products.tax_group_id
          INNER JOIN menu_categories ON menu_categories.id=menu_products.menu_category_id
          INNER JOIN sorts ON sorts.id=menu_products.sort_id
          INNER JOIN product_attribute_values ON product_attribute_values.product_id=menu_products.product_id AND product_attribute_values.code = 'short_description'" ) }
        
          File.open("#{Rails.root}/public/menu_cards/#{request.subdomain}_menu_card.csv", 'wb') do |f|
            f.write CSV.generate_line(@menu_products.columns) # WRITE HEADER IN CSV
            @menu_products.rows.each do |line|
              f.write CSV.generate_line(line)
            end 
          end
          @file_array <<  "#{request.subdomain}_menu_card.csv"  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'product' action
      api :GET, '/api/v2/menu_cards/:id/product/:product_id', "API to fetch details of a menu item."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with this resource will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["categories","products","lots","product_images"], :example => "resources=categories"}
      formats ['json']

      ### => 'product' API Defination      
      def product
        @menu_product = MenuProduct.find(params[:product_id])
        @resources = params[:resources].present? ? params[:resources].split(',') : ['products','product_images']
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception        
      end

      def mp_sale_rules
        @mp_sale_rules = MenuProductSaleRule.where(:menu_product_id=>params[:menu_product_id])
        puts @mp_sale_rules.inspect
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end