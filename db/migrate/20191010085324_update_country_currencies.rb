require 'rest-client'
require 'json'
class UpdateCountryCurrencies < ActiveRecord::Migration
  def up
  	RestClient::Request.new({
  		method: :get,
  		url: "https://free.currconv.com/api/v7/currencies?apiKey=5b12e17f67235aefcb7f"
  	}).execute do |response, request, result|
  		if JSON.parse(response)
  			currencies = JSON.parse(response)["results"]
  			currencies.each do |currency|
  				symbol  = currency[1]["currencySymbol"].present? ? currency[1]["currencySymbol"] : nil
  				if !CountryCurrency.find_by_currency(currency[1]["currencyName"]).present?
  					CountryCurrency.create(:currency=>currency[1]["currencyName"],:currency_code=>currency[1]["id"],:symbol=>symbol)
  				end
  			end
  		end
  	end
  end

  def down
  end
end
