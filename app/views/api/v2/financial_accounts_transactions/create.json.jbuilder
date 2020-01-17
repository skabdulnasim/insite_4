json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
    json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_proforma_transaction)
    json.internal_message @error.present? ? @error.message : I18n.t(:success_proforma_transaction)
    json.error_code @log[:log_serial] if @error.present? and @log.present?
    json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data  do
    json.extract! @financial_account, :id,:account_holder_id, :account_holder_type, :current_balance, :total_credit, :total_debit, :acc_no, :account_type
    if @financial_account.current_balance < 0
      json.due_amount @financial_account.current_balance * -1
    else
      json.due_amount 0
    end 
  end

end