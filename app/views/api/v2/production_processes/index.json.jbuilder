json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_records_found_with_count, count: @production_processes.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_records_found_with_count, count: @production_processes.count)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data do
    json.count @processes_count
    json.processes @production_processes do |production_process|
      json.extract! production_process, :id, :name
      json.image production_process.process_image
    end
  end
end