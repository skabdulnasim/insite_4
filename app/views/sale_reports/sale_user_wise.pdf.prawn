require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  _header_text = @unit.unit_detail.present? ? @unit.unit_detail.options[:bill_header_text] : @unit.unit_name
  pdf.text_box "#{_header_text}", :at => [5,70], :size => 10
  pdf.text_box "Sales by users across days", :at => [5,60], :size => 10
  pdf.text_box "To Date: #{params[:to_date]}",   :at => [500,50]
  pdf.text_box "From Date: #{params[:from_date]}", :at => [500,70]
  pdf.move_down 200 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
data = [["User","Bill Amount(without Tax)","Tax","Discount","Grand Total","Date"]]
@sales.each do |object|
  user = User.find(object.biller_id)
  _row = Array.new
  _row.push("#{user.profile.firstname} #{user.profile.lastname}") 
  _row.push(object.total_bill_amount) 
  _row.push(object.total_tax) 
  _row.push(object.total_discount) 
  _row.push(object.total_grand_total) 
  _row.push(object.date) 
  data += [_row] # Pushing row to PDF table
end 
pdf.table data, {:header => false, :width => 560} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  # table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end
