json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? "No record found" : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do    
    json.extract! @customer, :id, :email, :mobile_no, :created_at, :updated_at, :gstin, :business_type
    json.name "#{@customer.customer_profile.firstname}" " #{@customer.customer_profile.lastname}"
    json.extract! @customer.profile, :firstname, :lastname, :contact_no, :customer_id, :created_at, 
    :updated_at, :address, :gender, :age, :dob, :anniversary ,:pan_no if @customer.profile.present?
    json.profile_id @customer.profile.id if @customer.profile.present?
    json.boh_amount @boh_amount[0].total_boh_amount.to_f.round(2) if params[:boh_amount].present? && params[:boh_amount] == 'yes'
    json.bill_count @customer.bills.count
    json.addresses @customer.addresses do |address|
      json.extract! address, :id, :receiver_first_name, :receiver_last_name, :delivery_address, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude, :address_type
    end
    if @resources.include? 'wallet'
      if @customer.wallet.present?
        json.wallet do
          json.extract! @customer.wallet, :id, :current_balance, :total_credit, :total_debit
        end
      else
        json.wallet Hash.new
      end
    end  
    if @resources.include? 'financial_account'
      if @customer.financial_account.present?
        json.financial_account do
          json.extract! @customer.financial_account, :id,:account_holder_id, :account_holder_type, :current_balance, :total_credit, :total_debit, :acc_no, :account_type
          if @customer.financial_account.current_balance < 0
            json.due_amount @customer.financial_account.current_balance * -1
          else
            json.due_amount 0
          end
          json.proforma_due_amount @customer.proformas.by_billed_status(0).sum(:grand_total)
          # json.transaction_history @customer.financial_account.financial_account_transactions do |acc_transc|
          #   json.extract! acc_transc, :id, :amount, :transaction_type, :device_id, :purpose, :remarks
          #   json.created_at acc_transc.created_at.strftime("%d-%m-%Y, %I:%M %p")
          #   json.receiver_name acc_transc.user.profile.full_name
          #   json.paymentmode acc_transc.fat_paymentmode_type.split('Fat')[1]
          # end
        end
      else
        json.financial_account Hash.new
      end
    end
  end
end