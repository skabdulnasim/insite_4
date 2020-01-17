module Api
	module V2
		class VendorsController < ApplicationController
      api :GET, '/api/v2/vendors', "Get all vendors of an outlet"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "id of the unit whose vendors you want"
      #param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      #param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
			def index
				@vendors = Vendor.where(unit_id: params[:unit_id] ) if params[:unit_id].present?
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?
			end

      api :GET, '/api/v2/vendors/vendor_pjp', "Get Pjp of vendors"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :user_id, String, :required => true, :desc => "id of the user whose pjp you want"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      
      def vendor_pjp
        _per = params[:per] || 100
        @date_count = Time.days_in_month(Time.now.month, Time.now.year)
        if params[:page].present?
          _current_date = Date.today.beginning_of_month + ((params[:page].to_i - 1)* _per.to_i)
          _upto_date = _current_date + _per.to_i - 1
          _upto_date = Date.today.end_of_month if _upto_date > Date.today.end_of_month  
        else
          _current_date = Date.today.beginning_of_month
          _upto_date = Date.today.end_of_month
        end  
        @pjp_date = {}
        (_current_date.._upto_date).each do |t_date|
          arr = Array.new()
          vendor_allocations = UserVendor.by_date(t_date).by_user(params[:user_id])
          vendor_allocations.each do |va|
            vendor_products = Array.new()
            vendors = {}
            vendors["id"] = va.id
            vendors["vendor_id"] = va.vendor_id
            vendors["name"] = va.vendor.name
            vendors["phone"] = va.vendor.phone
            vendors["pan_no"] = va.vendor.pan_no
            vendors["address"] = va.vendor.address
            vendors["address_phone_no"] = va.vendor.address_phone_no
            vendors["unit_id"] = va.vendor.unit_id
            vendors["email"] = va.vendor.email
            vendors["gst_hash"] = va.vendor.gst_hash
            vendors["latitude"] = va.vendor.latitude
            vendors["longitude"] = va.vendor.longitude
            vendors["recorded_at"] = va.vendor.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
            va.vendor.vendor_products.each do |vp|
              vendor_product = {}
              vendor_product["id"] = vp.id
              vendor_product["vendor_id"] = va.vendor_id
              vendor_product["product_id"] = vp.product_id
              vendor_product["recorded_at"] = vp.recorded_at.strftime("%Y-%m-%d %H:%M:%S")
              vendor_products.push vendor_product
            end  
            vendors["vendor_products"] = vendor_products
            arr.push vendors
          end  
          @pjp_date[t_date] = arr
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
      end

			api :GET, '/api/v2/vendors/:id', "Get vendor product"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store_id, String, :required => true, :desc => "id of the vendor"
      param :stock_filter, String, :required => false, :desc => "stock status 1 for instock 2 for out stock"
      param :business_type, String, :required => false, :desc => "Product filter by business_type"
      param :category_id, String, :required => false, :desc => "Filter product by category_id"
      param :filter_string, String, :required => false, :desc => "fiter by product name"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results"
      param :per, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 100 results. If you want to define the number of results per page, you can do so by adding `per` parameter in your request.", :meta => "`per` parameter is dependent on `page` parameter"
      
			def show
				@store_id = params[:store_id]
				@vendor = Vendor.find(params[:id])
				_per = params[:per] || 100
        @products = @vendor.products.order('name asc')
        @products = @products.by_business_type(params[:business_type]) if params[:business_type].present?
        @products = @products.check_stock_status(@store_id,params[:stock_filter],'') if params[:stock_filter]
        @products = @products.by_category_id(params[:category_id]) if params[:category_id].present?
        @products = @products.filter_by_string(params[:filter_string]) if params[:filter_string].present?
        @product_count = @products.count
        @products = @products.page(params[:page]).per(_per) if params[:page].present?
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?
			end

			api :POST, '/api/v2/vendors', "Api to generate a vendor."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :vendor_details, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "name": "Vendor 38",
              "address": "Kolkata",
              "address_phone_no" : "1234567890",
              "phone": "1234567890",
              "unit_id": "7",
              "email": "abc@gmail.com",
              "gst_hash": "abc123",
              "latitude": "12.9718353",
              "longitude": "77.5958301",
              "recorded_at": "2016-04-02 11:50",
              "user_vendors_attributes":[
                {
                "visit_date": "2018-12-12",
                "user_id": 2,
                "recorded_at": "2016-04-02 11:50"
                }
              ],
              "vendor_products_attributes":[
                {
                  "product_id": "1",
                  "price": "2000",
                  "tax_group_id": "21",
                  "recorded_at": "2016-04-02 11:50"
                },
                {
                  "product_id": "2",
                  "recorded_at": "2016-04-02 11:50"
                }
              ]
            }
        EOS
      formats ['json']

      def create
        @vendor = Vendor.find_by_address_phone_no(params[:vendor_details][:address_phone_no])
        if @vendor.present?
          if params[:vendor_details][:user_vendors_attributes].present?
            params[:vendor_details][:user_vendors_attributes].each do |user_vendor|
              unless UserVendor.find_by_user_id_and_vendor_id(user_vendor['user_id'],@vendor.id).present?
                save_uv = UserVendor.new user_vendor
                save_uv[:vendor_id] = @vendor.id
                save_uv.save
              end  
            end
          end
          if params[:vendor_details][:vendor_products_attributes].present?
            params[:vendor_details][:vendor_products_attributes].each do |vendor_product|
              unless VendorProduct.by_vendor_product(vendor_product['product_id'],@vendor.id).present?
                save_vp = VendorProduct.new vendor_product
                save_vp[:vendor_id] = @vendor.id
                save_vp.save
              end  
            end
          end
          @status_code = 406
          @status_messge = "Vendor exit with this mobile no"
        else
          @vendor = Vendor.new(params[:vendor_details])
          unless @vendor.save
            @validation_errors = error_messages_for(@vendor)
  				end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/vendors/allocate_vendor_products', "Api to allocate products to a single vendor."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :vendor_product_details, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "vendor_id": "36",
              "vendor_products":[
                {
                  "product_id": "2",
                  "price": "800",
                  "tax_group_id": "21",
                  "recorded_at": "2016-04-02 11:50"
                },
                {
                  "product_id": "1",
                  "price": "100",
                  "recorded_at": "2016-04-02 11:50"
                }
              ]
            }
        EOS
      formats ['json']

      def allocate_vendor_products
        @vendor_id = params[:vendor_product_details]['vendor_id']
        @vendor = Vendor.find(@vendor_id)
        @newly_allocated_products = Array.new
        params[:vendor_product_details]['vendor_products'].each do |v_p|
          if VendorProduct.by_vendor_product(v_p['product_id'],@vendor.id).present?
            @newly_allocated_products.push v_p['product_id']
          else
            _vendor_product = VendorProduct.new
            _vendor_product.vendor_id = @vendor.id
            _vendor_product.product_id = v_p['product_id']
            _vendor_product.price = v_p['price']
            _vendor_product.tax_group_id = v_p['tax_group_id']
            if _vendor_product.save
              @newly_allocated_products.push _vendor_product.product_id
            end
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      api :POST, '/api/v2/vendors/vendor_contract_details', "Api to add details by Procurement staffs after visiting a vendor place"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :vendor_contract_details, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below 
            {
              "vendor_id": "38",
              "unit_id": "7",
              "latitude": "25.1786",
              "longitude": "88.2461",
              "visited_by": "5",
              "recorded_at": "2016-04-02 11:50",
              "vendor_product_prices_attributes": [
                {
                  "vendor_product_id": "10",
                  "product_id": "400",
                  "address_of_place": "Kolkata",
                  "delivery_starts": "2018-11-28",
                  "delivery_ends": "2018-11-29",
                  "delivery_rate_per_km": "10",
                  "discount": "10",
                  "quantity": "100",
                  "recorded_at": "2016-04-02 11:50",
                  "unit_price": "105",
                  "tax_inclusion": true,
                  "delivery_charge_inclision": false,
                  "total_agreed_qty": "200",
                  "supply_interval": "month",
                  "source_location": "Kolkata",
                  "destination_type": "Store",
                  "destination_id": "1"
                },
                {
                  "vendor_product_id": "20",
                  "product_id": "395",
                  "address_of_place": "Kolkata",
                  "delivery_starts": "2018-11-28",
                  "delivery_ends": "2018-11-29",
                  "delivery_rate_per_km": "10",
                  "discount": "10",
                  "quantity": "100",
                  "recorded_at": "2016-04-02 11:50",
                  "unit_price": "105",
                  "tax_inclusion": true,
                  "delivery_charge_inclision": false,
                  "total_agreed_qty": "200",
                  "supply_interval": "month",
                  "source_location": "Malda",
                  "destination_type": "Store",
                  "destination_id": "1"
                }
              ]
            }
        EOS
      formats ['json']

      def vendor_contract_details
        @vendor_contract = VendorContract.new(params[:vendor_contract_details])
        if @vendor_contract.save
          @vendor_contract.reload
        else
          @validation_errors = error_messages_for(@vendor_contract)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

		end
	end
end