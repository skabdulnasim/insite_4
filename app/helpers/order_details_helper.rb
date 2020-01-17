module OrderDetailsHelper
#########################################  Return jsons  ###############################################
  def orders_index_json(order_detail)
    order_detail.to_json(
    :include => [{:menu_product => {:include => :product}}, :order_detail_combinations => {:include => {:menu_product_combination => {:include => [:product, :combination_type]}}}])
  end
#########################################################################################################

#########################################  Api parameters  ##############################################
  def update_order_detail_status_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/order_details/update_order_detail_status.json', "Change the status of an order details. Ex : approved preparing prepared deivered"
    error :code => 401, :desc => "Unauthorized"
    param :user_id, String, :desc => "User ID", :required => false
    param :order_detail_ids, String, :desc => "order_detail_ids json as => [{'id':'125'},{'id':'126'}]", :required => true
    param :status, String, :desc => "Status ID any of approved preparing prepared deivered", :required => true
    description "Url : http://lazeez.stewot.com/orders/update_order_status.json"
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#    
  end

  def update_order_detail_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :PUT, '/order_details/:id', "Update product from an order. But dont send whole order, you have to send a singhe order details of an order"
    error :code => 401, :desc => "Unauthorized"
    param :id, :number
    param :order_details, String, :desc => "{'menu_product_id':103,'quantity':3,'parcel':1,'preferences':'Low chillidd','order_detail_combinations':[{'menu_product_combination_id':71, 'total_price':20, 'combination_qty':6}]}", :required => false 
    description "Cancel a product from an order."
    formats ['json', 'jsonp']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#   
  end

  def get_order_details_index_api
    #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :GET, '/order_details.json', "Get sorts"
    param :sort_id, String, :desc => "Sort ID", :required => false
    param :status, String, :desc => "status", :required => false
    error :code => 401, :desc => "Unauthorized"
    description "Url : http://sumit.lvh.me:3000/order_details.json?device_id=YOTTO05&sort_id=2&status=preparing2" 
    formats ['json', 'html']
    #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#   
  end
##############################################################################################################
end
