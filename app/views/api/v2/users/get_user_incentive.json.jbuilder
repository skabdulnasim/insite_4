json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do 
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Hash.new
else
	json.data do
		date = Date.current.beginning_of_month
		_tar = UserTarget.by_date(date).by_child_user(params[:user_id])
		_sale = UserSale.by_user_id(params[:user_id]).by_recorded_at_month(date.month)
		if _tar.present?
      if _tar[0].target_type == 'by_product'
        target_amount = _tar[0].user_target_products.sum(:target_quantity)
      else
        target_amount = _tar[0].target_amount
      end
    else
      target_amount = 0
    end
		_total_sale = _sale.present? ? _sale.sum(:quantity) : 0
		_achived_percentage = (_total_sale/target_amount) * 100
		json.achived_amount _total_sale
		json.achived_percentage _achived_percentage
		json.incentive_amount 0
	end
end