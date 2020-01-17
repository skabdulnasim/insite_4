module ThirdPartyPaymentOptionsHelper
  def third_party_payments_index_apipie_doc
    api :GET, '/third_party_payment_options.json', "Get list of all third party payment options"
    formats ['json', 'jsonp']    
    description "URL : http://dev.selfordering.com/third_party_payment_options.json?device_id=YOTTO05"
    error :code => 401, :desc => "Unauthorized"
  end  
end
