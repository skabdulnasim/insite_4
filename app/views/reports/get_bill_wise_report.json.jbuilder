json.status @error.present? ? "error" : "ok"
json.messages do
  json.simple_message @error.present? ? "Error occured while loading data" : "#{@array.count} datas loaded."
  json.internal_message @error.present? ? @error.message : "#{@array.count} data loaded."
  json.error_code "" if @error.present?
  json.error_url "" if @error.present?
end
if @error.present?
  json.data Hash.new
else
  json.data do
    json.total_bills @array[:total_bills]
    json.total_billed_amount @array[:total_billed]
    json.total_settled_amount @array[:total_settled]
    json.total_unsettled_amount @array[:total_unsettled]
    json.total_card_sale @array[:total_card_sale]
    json.total_cash_sale @array[:total_cash_sale]
    json.other_sale @array[:other_sale]
    json.total_nc @array[:nc]
    json.total_unpaid @array[:unpaid]
    json.total_cod @array[:cod]
    json.total_void @array[:void]
    json.total_pax @array[:total_pax]
    json.apc @array[:apc]
    json.section_bill @array[:section_bill]
    json.table_bill @array[:table_bill]
    json.take_away_bill @array[:take_away_bill]
    json.all_bills @array[:all_bills]
  end
end 