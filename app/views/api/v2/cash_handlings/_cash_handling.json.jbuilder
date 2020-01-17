json.extract! cash_handling, :id, :credit_amount, :debit_amount, :transaction_id, :transaction_type, :unit_id, :user_id, :available_amount, :device_id
json.reason cash_handling.pay_transaction.reason
json.created_at cash_handling.created_at.strftime("%d-%m-%Y, %I:%M %p")
json.transaction do
	json.data cash_handling
	if cash_handling.transaction_type == "CashIn" 
		json.extract! cash_handling.pay_transaction, :id, :amount, :reason, :bill_serial_no, :device_id, :recorded_at
	else
		json.extract! cash_handling.pay_transaction, :id, :amount, :reason, :device_id, :recorded_at
	end
	json.user cash_handling.user.email
	json.transaction_type cash_handling.transaction_type
	if cash_handling.transaction_type == "CashIn" and cash_handling.pay_transaction.cash_in_descriptions.present?
		json.description cash_handling.pay_transaction.cash_in_descriptions do |description|
			json.extract! description, :count
			json.image description.denomination.image
			json.value description.denomination.value
		end	
	elsif cash_handling.transaction_type == "CashOut"  and cash_handling.pay_transaction.cash_out_descriptions.present?
		json.description cash_handling.pay_transaction.cash_out_descriptions do |description|
			json.extract! description, :count
			json.image description.denomination.image
			json.value description.denomination.value
		end
	end
end

