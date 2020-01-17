json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do 
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @beneficiaries.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @beneficiaries.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Hash.new
else
  json.data do 
    json.count @count
    json.beneficiaries @beneficiaries do |beneficiaries|
      json.extract! beneficiaries, :id, :account_number, :bank_name, :ifsc, :name, :resource_id,:payment_mode,:branch,:beneficiary_type,:pan_no,:beneficiary_percentage
      json.previous_month_commission 10
      json.current_month_commission 10
    end
    _current_quarter_start_month = Time.zone.today.beginning_of_quarter.at_beginning_of_month
    _current_quarter_mid_month = _current_quarter_start_month + 1.month
    _current_quarter_end_month = _current_quarter_start_month + 2.month
    _year = Date.today.year
    if @quarter == 1
      json.quarter_data do
        
        json.January do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_start_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end 
        json.February do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_mid_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
        json.March do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_end_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
      end 
    elsif @quarter == 2
      json.quarter_data do
        json.April do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_start_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end 
        json.May do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_mid_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
        json.June do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_end_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
      end
    elsif @quarter == 3
      json.quarter_data do
        json.July do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_start_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end 
        json.August do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_mid_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
        json.September do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_end_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
      end
    elsif @quarter == 4
      json.quarter_data do
        json.October do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_start_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end 
        json.November do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_mid_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
        json.December do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id])
          if _tar.present?
            if _tar[0].target_type == 'by_product'
              target_amount = _tar[0].user_target_products.sum(:target_quantity)
            else
              target_amount = _tar[0].target_amount
            end
          else
            target_amount = 0
          end 
          _sale = UserSale.by_resource_id(params[:resource_id]).by_recorded_at_month(_current_quarter_end_month.month).by_recorded_at_year(_year)
          _total_sale = _sale.present? ? _sale.sum(:quantity) : 0
          _due = _tar.present? ? target_amount - _total_sale : 0
          json.target_amount target_amount
          json.achievement _sale.present? ? _total_sale : 0
          json.pending _due > 0 ? _due : 0
        end
      end 
    end 
  end
end