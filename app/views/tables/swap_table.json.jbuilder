json.status @error.present? ? "error" : "ok"
json.messages do
  json.simple_message @error.present? ? "Error occured while swapping tables" : "Table order swapping successfully completed"
  json.internal_message @error.present? ? @error.message : "Table order swapping successfully completed"
  json.error_code "" if @error.present?
  json.error_url "" if @error.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data Hash.new
end