json.status (@error.present? or !@customer.present?) ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  
  json.simple_message (@error.present? or !@customer.present?) ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.internal_message (@error.present? or !@customer.present?) ? I18n.t(:error_no_records_found) : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present? or !@customer.present?
  json.data Hash.new
else
  json.data do
    json.wallet_details @wallet, :id, :current_balance, :total_debit,:total_credit
    json.custmer_details do 
        json.id @wallet.customer.id
        json.phone @wallet.customer.mobile_no
        json.email @wallet.customer.email
        json.name "#{@wallet.customer.try(:profile).try(:firstname)} #{@wallet.customer.try(:profile).try(:lastname)}"
        json.gst_number @wallet.customer.gstin
        json.address @wallet.customer.addresses do |address|
            json.extract address, :id, :place, :locality, :city, :pincode, :state
        end
    end
  end

end