json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_no_records_found) : I18n.t(:success_unit_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_unit_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
    json.extract! @section, :id, :name, :additional_tax, :section_type
    json.bill_footer_text @section.bill_header
    json.bill_header_text @section.bill_footer
    json.tax_groups @section.tax_groups do |tax_group|
      json.extract! tax_group, :id, :name, :total_amnt, :fixed_amount
      json.tax_classes tax_group.active_tax_classes do |tax_class|
        json.extract! tax_class, :id, :name, :tax_type, :amount_type
        json.amount tax_class.ammount
      end
    end
  end
end