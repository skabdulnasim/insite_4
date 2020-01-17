json.extract! settlement, :id, :bill_id, :bill_amount, :status, :client_id, :client_type, :created_at, :updated_at, :recorded_at, :tips
# Adding client info
#client_name = "#{settlement.client.profile.firstname.humanize} #{settlement.client.profile.lastname.humanize}" if settlement.client.present? and settlement.client.profile.present? and settlement.client.profile.firstname.present?
if settlement.client_type == "Customer"
	client_name ||= "#{settlement.client.mobile_no}" if settlement.client.mobile_no.present?
else
	client_name ||= "#{settlement.client.email}" if settlement.client.present?
end	
client_name ||=""
json.client_name client_name
# Adding payment info
json.payments settlement.payments do |payment|
  json.extract! payment, :id, :paymentmode_id, :paymentmode_type, :created_at, :updated_at
  json.paid_amount payment.paymentmode.amount
  _payment_details = payment.paymentmode.third_party_payment_option_name if payment.paymentmode_type == 'ThirdPartyPayment'
  _payment_details ||= payment.paymentmode.room_name if payment.paymentmode_type == 'RoomPayment'
  _payment_details ||= payment.paymentmode.user_name if payment.paymentmode_type == 'AccountPayment'
  _payment_details ||= payment.paymentmode.name_on_card if payment.paymentmode_type == 'LoyaltyCardPayment'
  _payment_details ||= payment.paymentmode.wallet_name if payment.paymentmode_type == 'WalletPayment'
  _payment_details ||= payment.paymentmode.account_no if payment.paymentmode_type == 'FinalcialAccountPayment'
  _payment_details ||= ""
  json.paymentmode_details _payment_details
  if payment.paymentmode_type == 'Cash'
    json.transaction_currency_details payment.paymentmode.transaction_currency_details do |tcd|
      json.extract! tcd, :currency_symbol, :conversion_amount, :amount, :currency_code
    end  
  end  
end
