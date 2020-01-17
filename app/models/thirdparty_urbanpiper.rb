class ThirdpartyUrbanpiper

  def self.thirdparty_urbanpiper_order_status(thirdparty_order_id,status_json)
    urbanpiper_api_username = AppConfiguration.get_config('urbanpiper_api_username')
    urbanpiper_api_key = AppConfiguration.get_config('urbanpiper_api_key')
    urbanpiper_api_url = AppConfiguration.get_config('urbanpiper_api_url')

    if urbanpiper_api_username.present? && urbanpiper_api_key.present? && urbanpiper_api_url.present?
      puts "##*************************##"
      puts "#{urbanpiper_api_url}/external/api/v1/orders/#{thirdparty_order_id}/status/"
      puts status_json
      puts "##*************************##"
      response = RestClient::Request.new({
      method: :put,
      url: "#{urbanpiper_api_url}/external/api/v1/orders/#{thirdparty_order_id}/status/",
      payload: status_json,
      headers: {content_type: "application/json", Authorization:"apikey #{urbanpiper_api_username}:#{urbanpiper_api_key}"}
       }).execute do |response, request, result|
        puts JSON.parse(response)["status"]
        if JSON.parse(response)["status"] == "success"
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_urbanpiper_unit_upload(api_details,unit_parm)
    urbanpiper_api_username = api_details.api_username #AppConfiguration.get_config('urbanpiper_api_username')
    urbanpiper_api_key = api_details.api_key #AppConfiguration.get_config('urbanpiper_api_key')
    urbanpiper_api_url = api_details.api_url # AppConfiguration.get_config('urbanpiper_api_url')

    if urbanpiper_api_username.present? && urbanpiper_api_key.present? && urbanpiper_api_url.present?
      puts "##*************************##"
      puts "#{urbanpiper_api_url}/external/api/v1/stores/"
      puts unit_parm
      puts "##*************************##"

      response = RestClient::Request.new({
      method: :post,
      url: "#{urbanpiper_api_url}/external/api/v1/stores/",
      payload: unit_parm,
      headers: {content_type: "application/json", Authorization:"apikey #{urbanpiper_api_username}:#{urbanpiper_api_key}"}
       }).execute do |response, request, result|
        if JSON.parse(response)["status"] == "success"
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_urbanpiper_channel_toggle(api_details,_toggle_hash)
    urbanpiper_api_username = api_details.api_username #AppConfiguration.get_config('urbanpiper_api_username')
    urbanpiper_api_key = api_details.api_key #AppConfiguration.get_config('urbanpiper_api_key')
    urbanpiper_api_url = api_details.api_url # AppConfiguration.get_config('urbanpiper_api_url')

    if urbanpiper_api_username.present? && urbanpiper_api_key.present? && urbanpiper_api_url.present?
      puts "##*************************##"
      puts "#{urbanpiper_api_url}/hub/api/v1/items/"
      puts _toggle_hash
      puts "##*************************##"

      response = RestClient::Request.new({
      method: :post,
      url: "#{urbanpiper_api_url}/hub/api/v1/items/",
      payload: _toggle_hash,
      headers: {content_type: "application/json", Authorization:"apikey #{urbanpiper_api_username}:#{urbanpiper_api_key}"}
       }).execute do |response, request, result|
        if JSON.parse(response)["status"] == "success"
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_urbanpiper_unit_channel_toggle(api_details,unit_toggle_hash)
    urbanpiper_api_username = api_details.api_username #AppConfiguration.get_config('urbanpiper_api_username')
    urbanpiper_api_key = api_details.api_key #AppConfiguration.get_config('urbanpiper_api_key')
    urbanpiper_api_url = api_details.api_url # AppConfiguration.get_config('urbanpiper_api_url')

    if urbanpiper_api_username.present? && urbanpiper_api_key.present? && urbanpiper_api_url.present?
      puts "##*************************##"
      puts "#{urbanpiper_api_url}/hub/api/v1/location/"
      puts unit_toggle_hash
      puts "##*************************##"

      response = RestClient::Request.new({
      method: :post,
      url: "#{urbanpiper_api_url}/hub/api/v1/location/",
      payload: unit_toggle_hash,
      headers: {content_type: "application/json", Authorization:"apikey #{urbanpiper_api_username}:#{urbanpiper_api_key}"}
       }).execute do |response, request, result|
        if JSON.parse(response)["status"] == "success"
          return true
        else
          return false
        end
      end
    else
      return false
    end
  end

  def self.thirdparty_urbanpiper_cat_item_upload(api_details,menu_parm,unit_id)
    urbanpiper_api_username = api_details.api_username #AppConfiguration.get_config('urbanpiper_api_username')
    urbanpiper_api_key = api_details.api_key #AppConfiguration.get_config('urbanpiper_api_key')
    urbanpiper_api_url = api_details.api_url # AppConfiguration.get_config('urbanpiper_api_url')

    if urbanpiper_api_username.present? && urbanpiper_api_key.present? && urbanpiper_api_url.present?
      response = RestClient::Request.new({
      method: :post,
      url: "#{urbanpiper_api_url}/external/api/v1/inventory/locations/#{unit_id}/",
      payload: menu_parm,
      headers: {content_type: "application/json", Authorization:"apikey #{urbanpiper_api_username}:#{urbanpiper_api_key}"}
       }).execute do |response, request, result|
        return response
      end
    else
      resp ={}
      resp["status"] = "error"
      return resp.to_json
    end
  end

end