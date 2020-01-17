json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_financial_account_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_financial_account_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do 
    json.extract! @financial_account, :id,:account_holder_id, :account_holder_type, :current_balance, :total_credit, :total_debit, :acc_no, :account_type
    if @financial_account.current_balance < 0
      json.due_amount @financial_account.current_balance * -1
    else
      json.due_amount 0
    end
    json.count @account_transactions_count
    # Adding account transaction history
    json.transaction_history @account_transactions do |acc_transc|
      json.extract! acc_transc, :id, :amount, :transaction_type, :device_id, :purpose, :remarks
      json.created_at acc_transc.created_at.strftime("%d-%m-%Y, %I:%M %p")
      json.receiver_name acc_transc.user.profile.full_name
      json.paymentmode acc_transc.fat_paymentmode_type.split('Fat')[1]
    end
  end
end