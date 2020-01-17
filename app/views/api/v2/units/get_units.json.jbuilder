json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? "Sorry!! Could not find any branches" : "#{@units.count} branches loaded."
  json.internal_message @error.present? ? @error.message : "#{@units.count} units loaded."
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Array.new
else
  json.data(@units) do |unit|
    json.extract! unit, :id, :unit_name
    json.stores unit.stores do |store|
    	json.extract! store, :id, :name
    end
  end
end