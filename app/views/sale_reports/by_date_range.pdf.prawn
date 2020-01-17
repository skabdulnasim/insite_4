require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  _header_text = @unit.unit_detail.present? ? @unit.unit_detail.options[:bill_header_text] : @unit.unit_name
  pdf.text_box "#{_header_text}", :at => [5,70], :size => 10
  pdf.text_box "Sales Report by Range", :at => [150,50], :size => 20
  pdf.text_box "To Date: #{params[:to_date]}",   :at => [500,60]
  pdf.text_box "From Date: #{params[:from_date]}", :at => [490,70]
  pdf.move_down 20
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
preferences = ReportPreference.by_unit(current_user.unit_id).by_key('sales_report_by_date_range').first
_pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["date","total_billed_amount","total_discount","total_nc","total_void","total_unpaid_amount","total_settled_amount","cash","card","loyalty_card","third_party","total_tax"]
_pref_humanize =  _pref.map{|x| (x.humanize)}
_unit = Unit.find(@unit_id)
_unit_detail_options = _unit.unit_detail.options if _unit.unit_detail.present?
data = [_pref_humanize]
@dates.each do |date|
  _row = Array.new
  _from_datetime = date.to_date.beginning_of_day+_unit_detail_options[:day_closing_time].to_i.hours if _unit.unit_detail.present?
  _from_datetime ||= date.to_date.beginning_of_day
  _to_datetime = date.to_date.end_of_day+_unit_detail_options[:day_closing_time].to_i.hours if _unit.unit_detail.present?
  _to_datetime ||= date.to_date.end_of_day              
  settlement_data = Bill.get_unit_settlement_data(@unit_id,_from_datetime,_to_datetime)
  nc_void_data = Bill.invalid_bill.unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).group(:status).sum(:bill_amount)
  _total_sale = Bill.unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.grand_total}
  _total_discount = Bill.unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.discount}
  _total_tax = Bill.unit_bills(@unit_id).by_recorded_at(_from_datetime,_to_datetime).valid_bill.sum{|data| data.tax_amount}.round(2)
  _row.push(date) if _pref.include?('date')
  _row.push(_total_sale) if _pref.include?('total_billed_amount')
  _row.push(_total_discount) if _pref.include?('total_discount')
  _row.push(nc_void_data['no_charge'] || 0) if _pref.include?('total_nc')
  _row.push(nc_void_data['void'] || 0) if _pref.include?('total_void')
  _row.push((_total_sale.to_f - settlement_data[:total_settlement].to_f).round(1)) if _pref.include?('total_unpaid_amount')
  _row.push(settlement_data[:total_settlement]) if _pref.include?('total_settled_amount')
  _row.push(settlement_data[:cash_sale]) if _pref.include?('cash')
  _row.push(settlement_data[:card_sale]) if _pref.include?('card')
  _row.push(settlement_data[:loyalty_card_sale]) if _pref.include?('loyalty_card')
  _row.push(settlement_data[:third_party_sale]) if _pref.include?('third_party')
  _row.push(_total_tax) if _pref.include?('total_tax')
        
  Bill.report_attributes.each do |key, attributes|
    if key == "tax"
      attributes.each do |attribute|
        _row.push(Bill.tax_summery(@unit_id,_from_datetime,_to_datetime,attribute)[date]) if _pref.include?(attribute.parameterize)
      end            
    end      
  end  
  data += [_row]
end
pdf.table data, {:header => true, :width => 650} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  # table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end
       