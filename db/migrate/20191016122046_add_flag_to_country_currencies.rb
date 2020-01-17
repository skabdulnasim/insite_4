require 'rest-client'
require 'json'
class AddFlagToCountryCurrencies < ActiveRecord::Migration
  def change
    add_column :country_currencies, :flag, :text
    RestClient::Request.new({
  		method: :get,
  		url: "http://countryapi.gear.host/v1/Country/getCountries"
  	}).execute do |response, request, result|
  		if JSON.parse(response)
  			currencies = JSON.parse(response)["Response"]
  			currencies.each do |currency|
  				puts currency.inspect
  				if CountryCurrency.find_by_currency_code(currency["CurrencyCode"]).present?
  					CountryCurrency.find_by_currency_code(currency["CurrencyCode"]).update_attributes(:flag => currency["FlagPng"],:counrty=>currency["NativeName"],:symbol=>currency["CurrencySymbol"])
  				end
  			end
  		end
  	end
  end
end
