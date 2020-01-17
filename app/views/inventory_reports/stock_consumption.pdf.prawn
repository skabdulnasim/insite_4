require "prawn/table"
pdf.font_size 10

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 550, :height => 50, :font_size  => 14) do
  pdf.text_box "Store consumption report From Date: #{params[:from_date]}", :at => [50,70]
  pdf.text_box "To Date: #{params[:to_date]}", :at => [50,500]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end 
data = [["Product", "Total Stock Consumed"]]
@stocks.each do |object|
 data += [["#{object.product.name}", "#{object.total_debit} #{object.product.basic_unit}"]]
end
pdf.table data, {:header => false, :width => 550} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end