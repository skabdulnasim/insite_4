json.data @account_transactions do |acc_transc|
	json.extract! acc_transc, :id, :amount, :transaction_type, :device_id, :purpose, :remarks
	if acc_transc.recorded_at.present?
		json.created_at acc_transc.recorded_at.strftime("%d-%m-%Y, %I:%M %p")
	else
		json.created_at acc_transc.created_at.strftime("%d-%m-%Y, %I:%M %p")	
	end	
	json.receiver_name acc_transc.user.profile.full_name
	json.paymentmode acc_transc.fat_paymentmode_type.split('Fat')[1]
end