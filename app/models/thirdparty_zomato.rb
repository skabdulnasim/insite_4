class ThirdpartyZomato
	def self.thirdparty_zomato_menu_upload(menu_parm)  ###   UPLOAD
    zomato_api_key = AppConfiguration.get_config('zomato_api_key')
    if zomato_api_key.present?
      response = RestClient::Request.new({
      method: :post,
      url: "https://api.zomato.com/online-ordering/v2/menu/add",
      payload: menu_parm,
      headers: {content_type: "application/json", x_zomato_api_key: "#{zomato_api_key}", accept: "application/json"} 
       }).execute do |response, request, result|
        if JSON.parse(response)["menu_response"].present?
         	if JSON.parse(response)["menu_response"]["valid"] == true && JSON.parse(response)["menu_response"]["processed"] == true
         		return true
         	else
         		return false
         	end
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_zomato_menu_update(menu_parm)  ###    UPDATE
    zomato_api_key = AppConfiguration.get_config('zomato_api_key')
    if zomato_api_key.present?
      response = RestClient::Request.new({
      method: :post,
      url: "https://api.zomato.com/online-ordering/v2/menu/update",
      payload: menu_parm,
      headers: {content_type: "application/json", x_zomato_api_key: "#{zomato_api_key}", accept: "application/json"} 
       }).execute do |response, request, result|
        if JSON.parse(response)["menu_response"].present?
          if JSON.parse(response)["menu_response"]["valid"] == true && JSON.parse(response)["menu_response"]["processed"] == true
            return true
          else
            return false
          end
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_zomato_status_confirm(status_parm)
    zomato_api_key = AppConfiguration.get_config('zomato_api_key')
    if zomato_api_key.present?
      response = RestClient::Request.new({
      method: :post,
      url: "​https://api.zomato.com/online-ordering/v1/order/confirm",
      payload: status_parm,
      headers: {content_type: "application/json", x_zomato_api_key: "#{zomato_api_key}", accept: "application/json"} 
       }).execute do |response, request, result|
        if JSON.parse(response)["status"].present?
          if JSON.parse(response)["status"] == "success"
            return true
          else
            return false
          end
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_zomato_status_reject(status_parm)
    zomato_api_key = AppConfiguration.get_config('zomato_api_key')
    if zomato_api_key.present?
      response = RestClient::Request.new({
      method: :post,
      url: "​​https://api.zomato.com/online-ordering/v1/order/reject",
      payload: status_parm,
      headers: {content_type: "application/json", x_zomato_api_key: "#{zomato_api_key}", accept: "application/json"} 
       }).execute do |response, request, result|
        if JSON.parse(response)["status"].present?
          if JSON.parse(response)["status"] == "success"
            return true
          else
            return false
          end
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_zomato_status_pickedup(status_parm)
    zomato_api_key = AppConfiguration.get_config('zomato_api_key')
    if zomato_api_key.present?
      response = RestClient::Request.new({
      method: :post,
      url: "​​https://api.zomato.com/online-ordering/v1/order/pickedup",
      payload: status_parm,
      headers: {content_type: "application/json", x_zomato_api_key: "#{zomato_api_key}", accept: "application/json"} 
       }).execute do |response, request, result|
        if JSON.parse(response)["status"].present?
          if JSON.parse(response)["status"] == "success"
            return true
          else
            return false
          end
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_zomato_status_delivered(status_parm)
    zomato_api_key = AppConfiguration.get_config('zomato_api_key')
    if zomato_api_key.present?
      response = RestClient::Request.new({
      method: :post,
      url: "​​​https://api.zomato.com/online-ordering/v1/order/delivered",
      payload: status_parm,
      headers: {content_type: "application/json", x_zomato_api_key: "#{zomato_api_key}", accept: "application/json"} 
       }).execute do |response, request, result|
        if JSON.parse(response)["status"].present?
          if JSON.parse(response)["status"] == "success"
            return true
          else
            return false
          end
        else
          return false
        end
      end
    else
      return false
    end
  end

end