json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @news_events.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @news_events.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data @news_events do |news_event|
    _news_event = news_event.news_event
    if _news_event.valid_till >= Date.today
	    json.extract! _news_event, :id, :name, :description, :valid_from, :valid_till, :position, :repeating
	    json.news_event_image _news_event.news_event_galleries.first.news_event_image_file_name
	    json.news_event_image_url _news_event.news_event_galleries.first.news_event_image.url(:original)
	  end  
  end
end