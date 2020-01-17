json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_listing_slot) : I18n.t(:success_listing_slot)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_listing_slot)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end
if @error.present?
  json.data Array.new
else
  json.data @availability do |available|
  	slot = Slot.find(available.slot_id)
    json.extract! slot, :id, :title, :start_time, :end_time, :duration
  end
end