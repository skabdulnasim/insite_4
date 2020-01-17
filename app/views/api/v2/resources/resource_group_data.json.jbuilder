json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data do
    _current_quarter_start_month = Time.zone.today.beginning_of_quarter.at_beginning_of_month
    _current_quarter_mid_month = _current_quarter_start_month + 1.month
    _current_quarter_end_month = _current_quarter_start_month + 2.month
    if @quarter == 1
      json.quarter_data do
        
        json.January do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end 
        json.February do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
        json.March do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
      end 
    elsif @quarter == 2
      json.quarter_data do
        json.April do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end 
        json.May do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
        json.June do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
      end
    elsif @quarter == 3
      json.quarter_data do
        json.July do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end 
        json.August do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
        json.September do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
      end
		elsif @quarter == 4
      json.quarter_data do
        json.October do
          _tar = ResourceTarget.by_date(_current_quarter_start_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end 
        json.November do
          _tar = ResourceTarget.by_date(_current_quarter_mid_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
        json.December do
          _tar = ResourceTarget.by_date(_current_quarter_end_month).set_resource(params[:resource_id]) if params[:resource_id].present?
          json.target_amount _tar.present? ? _tar[0].target_amount : 0
          json.achievement 10
          json.pending 10
        end
      end 
    end 
  end
end