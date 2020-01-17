require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 540, :height => 50, :font_size  => 14) do
  _header_text = "BOH Sales Report Between Date #{params[:from_date]} to #{params[:to_date]}"
  pdf.text_box "#{_header_text}", :at => [140,50], :size => 10
  pdf.move_down 200 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
preferences = ReportPreference.by_unit(current_user.unit_id).by_key('boh_sales_by_date').first
_pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["Bill Id", "Grand Total", "Boh Amount", "Biller", "Customer Name", "Customer Mobile", "Date", "Created Date"]
_pref_humanize =  _pref.map{|x| (x.humanize)}
data = [_pref_humanize]
@bills.each do |bill|
  _row = Array.new
  _row.push(bill.id)
  _row.push(bill.grand_total)
  _row.push(bill.boh_amount)
  _row.push("#{bill.biller.profile.firstname} #{bill.biller.profile.lastname}")
  _row.push("#{bill.customer.profile.firstname} #{bill.customer.profile.lastname} ")
  _row.push(bill.customer.mobile_no)
  _row.push(bill.recorded_at.strftime("%d-%m-%Y, %I:%M %p") )
  _row.push("#{bill.recorded_at.strftime('%d-%m-%Y, %I:%M %p')}")
  data += [_row] # Pushing row to PDF table
end
pdf.table data, {:header => false, :width => 540} do |table|
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end
