class ExternalOrder < ActiveRecord::Base
  attr_accessible :order, :customer, :order_id, :order_source, :external_order_id, :unit_id, :thirdparty_status
  after_create :after_external_order_placed

  # belongs_to :order

  private
  def after_external_order_placed
    self.customer = self.customer.tr('”','"')
    self.order = self.order.tr('”','"')
    self.customer = self.customer.tr('“','"')
    self.order = self.order.tr('“','"')
    
  	# Insert External Customer
    if self.order_source=="urban_piper"     #  URBANPIPER INTEGATION START HERE  #
      @exsist_cus = Customer.find_by_mobile_no(JSON.parse(self.customer)["phone"]) if JSON.parse(self.customer)["phone"].present?
      if @exsist_cus.present?
        @customer = Customer.find_by_mobile_no(JSON.parse(self.customer)["phone"])
      else
        @customer = Customer.new(urbanpiper_customer_params)
        @customer.save
      end

      current_time = Time.zone.now #DateTime.now.strftime("%Y-%m-%d %I:%M")
      # _user = User.find_by_email_and_unit_id(params[:email],JSON.parse(self.order)["store"]["merchant_ref_id"])
      # Insert External Address
      @address_hash = {
        "city"                =>  JSON.parse(self.customer)["address"]["city"], 
        "contact_no"          =>  JSON.parse(self.customer)["phone"], 
        "customer_id"         =>  @customer.id, 
        "delivery_address"    =>  JSON.parse(self.customer)["address"]["sub_locality"]+", "+JSON.parse(self.customer)["address"]["city"]+", PIN - "+JSON.parse(self.customer)["address"]["pin"],  
        "landmark"            =>  JSON.parse(self.customer)["address"]["sub_locality"], 
        "latitude"            =>  JSON.parse(self.customer)["address"]["latitude"], 
        "locality"            =>  JSON.parse(self.customer)["address"]["sub_locality"], 
        "longitude"           =>  JSON.parse(self.customer)["address"]["longitude"], 
        "pincode"             =>  JSON.parse(self.customer)["address"]["pin"], 
        "place"               =>  JSON.parse(self.customer)["address"]["sub_locality"], 
        "receiver_first_name" =>  JSON.parse(self.customer)["name"],
        "receiver_name"       =>  JSON.parse(self.customer)["name"]
      }
      @ord_address = Address.new(@address_hash)
      @ord_address.save

      # Insert External Order
      @order_hash = {
        "deliverable_type"       =>   "Address",
        "deliverable_id"         =>   @ord_address.id,
        "device_id"              =>   "YOTTO05",
        "resource_type"          =>   "table",
        "consumer_type"          =>   "Customer",
        "consumer_id"            =>   @customer.id,
        "order_status_id"        =>   "1",
        "delivery_type"          =>   JSON.parse(self.order)["details"]["ext_platforms"].present? ?JSON.parse(self.order)["details"]["ext_platforms"][0]["delivery_type"] : "self",
        "source"                 =>   JSON.parse(self.order)["details"]["channel"],
        "unit_id"                =>   JSON.parse(self.order)["store"]["merchant_ref_id"],
        "delivary_date"          =>   Time.strptime(JSON.parse(self.order)["details"]["delivery_datetime"].to_s,'%Q'), #Time.at(JSON.parse(self.order)["details"]["delivery_datetime"].to_f/1000.0), #.in_time_zone("Asia/Kolkata")
        "recorded_at"            =>   Time.strptime(JSON.parse(self.order)["details"]["created"].to_s,'%Q'), #Time.at(JSON.parse(self.order)["details"]["created"].to_f/1000.0), #.in_time_zone("Asia/Kolkata")
        "customer_id"            =>   @customer.id,
        "latitude"               =>   JSON.parse(self.customer)["address"]["latitude"],
        "longitude"              =>   JSON.parse(self.customer)["address"]["longitude"],
        "address_id"             =>   @ord_address.id,
        "third_party_order_id"   =>   self.external_order_id
      }

      @ex_order_id = JSON.parse(self.order)["details"]["id"]

      @order_details_attributes=[]
      JSON.parse(self.order)["items"].each do |item|
        mmp=MenuProduct.find(item["merchant_id"])
        msection = mmp.menu_card.section
        csection = Section.find_by_unit_id_and_master_section_id(JSON.parse(self.order)["store"]["merchant_ref_id"],msection.id)
        mps=MenuProduct.set_product_and_section(mmp.product_id,csection.id)
        mp=mps[0]
        if mp.product.product_type == 'variable'
          item["options_to_add"].each do |citem|
            hash_data = {}
            cmmp=MenuProduct.find(item["merchant_id"])
            cmps=MenuProduct.set_product_and_section(cmmp.product_id,csection.id)
            hash_data["menu_product_id"]= cmps[0].id.to_s
            hash_data["quantity"] = item["quantity"].to_s
            hash_data["parcel"] = "0"
            @order_details_attributes << hash_data
          end
        else
          hash_data = {}
          hash_data["menu_product_id"]= mp.id.to_s
          hash_data["quantity"] = item["quantity"].to_s
          hash_data["parcel"] = "0"
          if item["options_to_add"].present?
            @order_detail_combinations_attributes = []
            item["options_to_add"].each do |citem|
              order_detail_combination = {}
              combination_item = MenuProductCombination.find_by_menu_product_id_and_product_id(mp.id.to_s,citem["merchant_id"].to_s)
              order_detail_combination["menu_product_combination_id"]= combination_item.id if combination_item.present?
              order_detail_combination["combination_qty"] = combination_item.ammount if combination_item.present?
              @order_detail_combinations_attributes << order_detail_combination
            end
            hash_data["order_detail_combinations_attributes"] = @order_detail_combinations_attributes
          end
          @order_details_attributes << hash_data
        end
      end
      @order_hash["order_details_attributes"]=@order_details_attributes

      _checksum_order = Digest::MD5.hexdigest(Marshal::dump(@order_hash.collect{|k,v| [k,v]}.sort{|a,b| a[0] <=> b[0]}))
      @order_hash["checksum"] = _checksum_order

      hash_order = {}
      hash_order["order"]= @order_hash

      @ord = Order.new(@order_hash)
      if @ord.save
        self.update_attributes(:order_id =>  @ord.id, :unit_id => JSON.parse(self.order)["store"]["merchant_ref_id"])

        # @status_hash={}
        # @status_hash["new_status"] = "Acknowledged",
        # @status_hash["message"] = "Order Acknowledged"
        # puts ThirdpartyUrbanpiper.thirdparty_urbanpiper_order_status(@ex_order_id,@status_hash.to_json)
        bmmp=MenuProduct.find(JSON.parse(self.order)["items"][0]["merchant_id"])
        bmsection = bmmp.menu_card.section
        _section = Section.find_by_unit_id_and_master_section_id(JSON.parse(self.order)["store"]["merchant_ref_id"],bmsection.id)

        # _section = MenuProduct.find(JSON.parse(self.order)["items"][0]["merchant_id"]).menu_card.section
        _coupon = JSON.parse(self.order)["details"]["coupon"].present? ? JSON.parse(self.order)["details"]["coupon"] : "DISCOUNT"
        _bill_discount_param = []
        if JSON.parse(self.order)["details"]["ext_platforms"].present?
          if JSON.parse(self.order)["details"]["ext_platforms"][0].present?
            if JSON.parse(self.order)["details"]["ext_platforms"][0]["discounts"].present?
              JSON.parse(self.order)["details"]["ext_platforms"][0]["discounts"].each do |_dc|
                _bill_discount_hash = {}
                _bill_discount_hash["discount_amount"]      = _dc["value"].to_f if _dc["value"].present?
                _bill_discount_hash["remarks"]              = _dc["code"] if _dc["code"].present?
                _bill_discount_hash["is_merchant_discount"] = _dc["is_merchant_discount"].present? ? _dc["is_merchant_discount"].to_s : false 
                _bill_discount_hash["title"]                = _dc["title"] if _dc["title"].present?
                _bill_discount_hash["rate"]                 = _dc["rate"].to_f if _dc["rate"].present?
                _bill_discount_param.push(_bill_discount_hash)
              end
            end
          end
        end
        _bill_params = {
          "unit_id"           => @ord.unit_id ,
          "serial_no"         => "#{Time.now.strftime("%Y-%m-%d")}-#{@ord.id}",
          "biller_id"         => @customer.id,
          "biller_type"       => "Customer",
          "deliverable_id"    => @ord.deliverable_id,
          "deliverable_type"  => @ord.deliverable_type,
          "section_id"        => _section.id,
          "device_id"         => "YOTTO05",
          "bill_orders_attributes" => [{order_id: "#{@ord.id}"}],
          "bill_discounts_attributes" =>_bill_discount_param
          # "bill_discounts_attributes" => (JSON.parse(self.order)["details"]["discount"].present? and JSON.parse(self.order)["details"]["discount"].to_f > 0) ? [{"discount_amount" => JSON.parse(self.order)["details"]["discount"].to_f - JSON.parse(self.order)["details"]["total_external_discount"].to_f, "remarks" => _coupon}] : []
        }
        @bill = Bill.new(_bill_params)
        _third_party_payment_option = ThirdPartyPaymentOption.find_by_name(@ord.source)
        if @bill.save
          _settelment_params = {
            "bill_id"       => @bill.id,
            "tips"          => "0",
            "client_id"     => @customer.id,
            "client_type"   => "customer",
            "device_id"     =>"YOTTO05",
            "recorded_at"   =>"#{Time.now.strftime("%Y-%m-%d %H:%M")}",
            "payments_attributes"=>[                 
             {
                "paymentmode_type" => "ThirdPartyPayment",
                "paymentmode_attributes" =>{
                  "third_party_payment_option_id" => _third_party_payment_option.present? ? _third_party_payment_option.id : 1,
                  "amount" => @bill.grand_total          
                }
             }                                                                              
            ]
          }

          @settlement = Settlement.new(_settelment_params)
          @settlement.save
        end

      end

    elsif self.order_source=="zomato"   #  ZOMATO INTEGATION START HERE  #
      @exsist_cus = Customer.find_by_mobile_no(JSON.parse(self.order)["customer_details"]["phone_number"]) if JSON.parse(self.order)["customer_details"]["phone_number"].present?
      if @exsist_cus.present?
        @customer = Customer.find_by_mobile_no(JSON.parse(self.order)["customer_details"]["phone_number"])
      else
        @customer = Customer.new(zomato_customer_params)
        @customer.save
      end

      current_time = DateTime.now.strftime("%Y-%m-%d %I:%M")

      # Insert External Address START
      @address_hash = {}
      @address_hash["city"] = JSON.parse(self.order)["customer_details"]["city"].present? ? JSON.parse(self.order)["customer_details"]["city"] : " "
      @address_hash["contact_no"] = JSON.parse(self.order)["customer_details"]["phone_number"].present? ? JSON.parse(self.order)["customer_details"]["phone_number"] : " "
      @address_hash["customer_id"] =  @customer.id
      @address_hash["delivery_address"] = JSON.parse(self.order)["customer_details"]["address"].present? ? JSON.parse(self.order)["customer_details"]["address"] : " "
      @address_hash["landmark"]  = JSON.parse(self.order)["customer_details"]["address_instructions"].present? ? JSON.parse(self.order)["customer_details"]["address_instructions"] : " "
      @address_hash["latitude"] = JSON.parse(self.order)["customer_details"]["delivery_area_latitude"].present? ? JSON.parse(self.order)["customer_details"]["delivery_area_latitude"] : " "
      @address_hash["locality"] = JSON.parse(self.order)["customer_details"]["address_instructions"].present? ? JSON.parse(self.order)["customer_details"]["address_instructions"] : " "
      @address_hash["longitude"] = JSON.parse(self.order)["customer_details"]["delivery_area_longitude"].present? ? JSON.parse(self.order)["customer_details"]["delivery_area_longitude"] : " "
      @address_hash["pincode"] = JSON.parse(self.order)["customer_details"]["pincode"].present? ? JSON.parse(self.order)["customer_details"]["pincode"] : " "
      @address_hash["place"] = JSON.parse(self.order)["customer_details"]["pincode"].present? ? JSON.parse(self.order)["customer_details"]["pincode"] : " "
      @address_hash["receiver_first_name"] = JSON.parse(self.order)["customer_details"]["name"].present? ? JSON.parse(self.order)["customer_details"]["name"] : " "
      @address_hash["receiver_last_name"] = JSON.parse(self.order)["customer_details"]["name"].present? ? JSON.parse(self.order)["customer_details"]["name"] : " "
      @address_hash["receiver_name"] = JSON.parse(self.order)["customer_details"]["name"].present? ? JSON.parse(self.order)["customer_details"]["name"] : " "

      @ord_address = Address.new(@address_hash)
      @ord_address.save
      # Insert External Address END

      # Insert External Order START
      @order_hash = {}
      @order_hash["deliverable_type"] = "Customer"
      @order_hash["deliverable_id"] = @customer.id
      @order_hash["device_id"] = "YOTTO05"
      @order_hash["resource_type"] = "table"
      @order_hash["consumer_type"] = "Customer"
      @order_hash["consumer_id"] = @customer.id
      @order_hash["order_status_id"] = "1"
      @order_hash["source"] = "zomato"
      @order_hash["unit_id"] = JSON.parse(self.order)["outlet_id"]
      @order_hash["delivary_date"] = current_time
      @order_hash["recorded_at"] = current_time
      @order_hash["customer_id"] = @customer.id
      @order_hash["latitude"] = JSON.parse(self.order)["customer_details"]["delivery_area_latitude"].present? ? JSON.parse(self.order)["customer_details"]["delivery_area_latitude"] : " "
      @order_hash["longitude"] = JSON.parse(self.order)["customer_details"]["delivery_area_longitude"].present? ? JSON.parse(self.order)["customer_details"]["delivery_area_longitude"] : " "
      @order_hash["address_id"] = @ord_address.id

      @order_details_attributes=[]
      JSON.parse(self.order)["order_items"].each do |item|
        mp=MenuProduct.find(item["item_id"])
        if mp.product.product_type == 'variable'
          item["groups"].each do |gp|
            gp["items"].each do |citem|
              hash_data = {}
              hash_data["menu_product_id"]= citem["item_id"].to_s
              hash_data["quantity"] = citem["item_quantity"].to_s
              hash_data["parcel"] = "0"
              @order_details_attributes << hash_data
            end
          end
        else
          hash_data = {}
          hash_data["menu_product_id"]= item["item_id"].to_s
          hash_data["quantity"] = item["item_quantity"].to_s
          hash_data["parcel"] = "0"
          @order_details_attributes << hash_data
        end
      end
      @order_hash["order_details_attributes"] = @order_details_attributes

      hash_order = {}
      hash_order["order"]= @order_hash

      @ord = Order.new(@order_hash)
      @ord.save
      self.update_attributes(:order_id =>  @ord.id, :unit_id => JSON.parse(self.order)["outlet_id"])
      # Insert External Order END
    end #  ZOMATO INTEGATION END  #
  end

  # SET External Urbanpiper Customer Params
  def urbanpiper_customer_params
    address_val = JSON.parse(self.customer)["address"]["city"].present? ? JSON.parse(self.customer)["address"]["city"] : " "
    address_val = address_val +", PIN - "+JSON.parse(self.customer)["address"]["pin"] if JSON.parse(self.customer)["address"]["pin"].present?
    
    # Return Parms START
	  { 
	    "email"                          =>  JSON.parse(self.customer)["email"],
	    "mobile_no"                      =>  JSON.parse(self.customer)["phone"],
	    "password"                       =>  "12345678",

	    "customer_profile_attributes"  => 
	    {
	      "firstname"  =>  JSON.parse(self.customer)["name"],
	      "contact_no"  =>  JSON.parse(self.customer)["phone"],
	      "address"  =>  address_val
	    }      
	  }
    # Return Parms END
	end

  def zomato_customer_params   
    address_val = JSON.parse(self.order)["customer_details"]["address"].present? ? JSON.parse(self.order)["customer_details"]["address"] : " "
    address_val = address_val + ", City - "+JSON.parse(self.order)["customer_details"]["city"] if JSON.parse(self.order)["customer_details"]["city"].present?
    address_val = address_val + ", State - "+JSON.parse(self.order)["customer_details"]["state"] if JSON.parse(self.order)["customer_details"]["state"].present?
    address_val = address_val + ", Country - "+JSON.parse(self.order)["customer_details"]["country"] if JSON.parse(self.order)["customer_details"]["country"].present?
    address_val = address_val + ", PIN - "+JSON.parse(self.order)["customer_details"]["pincode"] if JSON.parse(self.order)["customer_details"]["pincode"].present?
    # Return Parms START
    { 
      "email"                          =>  JSON.parse(self.order)["customer_details"]["email"],
      "mobile_no"                      =>  JSON.parse(self.order)["customer_details"]["phone_number"],
      "password"                       =>  "12345678",

      "customer_profile_attributes"  => 
      {
        "firstname"  =>  JSON.parse(self.order)["customer_details"]["name"],
        "contact_no"  =>  JSON.parse(self.order)["customer_details"]["phone_number"],
        "address"  => address_val
      }      
    }
    # Return Parms END
  end

end 

# DEVELOPED BY GAS BABA