require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  _header_text = @unit.unit_detail.present? ? @unit.unit_detail.options[:bill_header_text] : @unit.unit_name
  pdf.text_box "#{_header_text}", :at => [5,70], :size => 10
  pdf.text_box "Date: #{params[:from_date]}", :at => [500,70]
  pdf.move_down 200 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
preferences = ReportPreference.by_unit(current_user.unit_id).by_key('sales_report_by_date').first
_pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["bill_id","deliverables_at","bill_amount_without_tax","total_tax","discount","total","status","user","remarks"]
_pref_humanize =  _pref.map{|x| (x.humanize)}
data = [_pref_humanize]
@sales.each do |bill|
  _row = Array.new
  _row.push(bill.id) if _pref.include?('bill_id')
  _row.push("#{bill.suffix}""#{bill.serial_no}""#{bill.prefix}") if _pref.include?('bill_serial')
  _row.push(bill.orders.first.source) if _pref.include?('order_source')
  if bill.orders.first.present?
    _order = bill.orders.first
    if ['Address','Customer'].include?(_order.deliverable_type)
      _row.push(_order.deliverable_type) if _pref.include?('deliverables_at')
    else
      _row.push("#{_order.deliverable_type}: #{_order.deliverable.name} (##{_order.deliverable_id})") if _pref.include?('deliverables_at')
    end
  else
    _row.push("_")  
  end  
  _row.push(bill.bill_amount) if _pref.include?('bill_amount_without_tax')
  _row.push(bill.tax_amount) if _pref.include?('total_tax')
  _row.push(bill.discount) if _pref.include?('discount')
  _row.push(bill.grand_total) if _pref.include?('total')
  _row.push(bill.status) if _pref.include?('status')
  _row.push("#{bill.biller.profile.firstname} #{bill.biller.profile.lastname}") if _pref.include?('user')
  _row.push(bill.remarks) if _pref.include?('remarks')
  _row.push("#{bill.recorded_at.strftime('%d-%m-%Y, %I:%M %p')}") if _pref.include?('date')
  
  Bill.report_attributes.each do |key, attributes|
    if key == "payment"
      attributes.each do |attribute|
        _row.push(bill.payment(attribute)) if _pref.include?(attribute.parameterize)
      end
    end
    if key == "tax"
      attributes.each do |attribute|
        _row.push(bill.tax(attribute)) if _pref.include?(attribute.parameterize)
      end            
    end      
  end
  data += [_row] # Pushing row to PDF table
end 
pdf.table data, {:header => false, :width => 650} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  # table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end
