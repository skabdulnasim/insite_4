class ExpectedCurrenciesController < ApplicationController
	include SmartListing::Helper::ControllerExtensions
	helper  SmartListing::Helper
	def index
		@currencies = CountryCurrency.order("currency ASC")
		@accepted_currencies = AcceptedCurrency.all
		smart_listing_create :currency,@currencies,:partial=>"expected_currencies/currency_smart_list"
		respond_to do |format|
      format.html # index.html.erb
      format.js
    end
	end
	
	def create
		new_accepted_currency = AcceptedCurrency.new(params[:accecpted_currency])
		if new_accepted_currency.save
			data = {:status=>"success",:accepted_currency=>build_response_hash(new_accepted_currency)}
		else
			data = {:status=>"error"}
		end
		puts data
		respond_to do |format|
			format.json{render json: { "data" => data }}
		end
	end
	def update_multiplier
		update_currency = AcceptedCurrency.where("country_currency_id=?",params[:accecpted_currency][:country_currency_id]).first
		update_currency.update_attributes({:multiplier=>params[:accecpted_currency][:multiplier],:status=>params[:accecpted_currency][:status]})
		data = {:status=>"success",:accepted_currency=>build_response_hash(update_currency)}
		respond_to do |format|
			format.json{render json: { "data" => data }}
		end
	end
	private
	def build_response_hash(accepted_currency)
		currency_details = Hash.new
		currency_details["currency"] = accepted_currency.country_currency.currency
		currency_details["currency_code"] = accepted_currency.country_currency.currency_code
		currency_details["country_currency_id"] = accepted_currency.country_currency_id
		currency_details["multiplier"] = accepted_currency.multiplier
		return currency_details
	end 
end
