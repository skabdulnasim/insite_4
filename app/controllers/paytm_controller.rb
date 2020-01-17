class PaytmController < ApplicationController
	include PaytmHelper
  #before_filter :authenticate_user!
  before_filter :get_paytm_keys

  def start_payment
		#add application logic unique to your app
    paramList = Hash.new
    paramList["MID"] = @paytm_keys['MID']
    paramList["ORDER_ID"] = "#{Time.now.to_i.to_s}"
    paramList["CUST_ID"] = "#{Time.now.to_i.to_s}"
    paramList["INDUSTRY_TYPE_ID"] = @paytm_keys['INDUSTRY_TYPE_ID']
    paramList["CHANNEL_ID"] = @paytm_keys['CHANNEL_ID']
    paramList["TXN_AMOUNT"] = 1
    paramList["MSISDN"] = '9674442296'
    paramList["EMAIL"] = 'gobinda.manna67@gmail.com'
    paramList["WEBSITE"] = @paytm_keys['WEBSITE']
    @paramList=paramList
    @checksum_hash=generate_checksum()
    puts @checksum_hash.inspect
    respond_to do |format|
      format.js
      format.html
    end
  end

  def verify_payment
    paytmparams = Hash.new
    keys = params.keys
    keys.each do |k|
      paytmparams[k] = params[k]
    end
    @checksum_hash = paytmparams["CHECKSUMHASH"]
    paytmparams.delete("CHECKSUMHASH")
    paytmparams.delete("controller")
    paytmparams.delete("action")
    @paytmparams = paytmparams
    @is_valid_checksum = verify_checksum()

    if @is_valid_checksum == true
      if @paytmparams["STATUS"] == "TXN_SUCCESS"
        #add application logic unique to your app
        respond_to do |format|
          format.html
        end
      else
      	#add application logic unique to your app
        respond_to do |format|
          format.html
        end
      end
    end
  end

  private

  def get_paytm_keys
    @paytm_keys=Rails.application.config.paytm_keys
  end
end
