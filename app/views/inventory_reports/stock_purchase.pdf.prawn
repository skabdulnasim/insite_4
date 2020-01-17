require "prawn/table"
pdf.font_size 10

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 12) do
  
  pdf.text_box "#{@stores.first.name}", :at => [5,40], :size => 10
  pdf.text_box "Date: #{params[:from_date]}", :at => [450,70]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
data = [["Stock Purchase ID", "Reference", "Vendor", "Total Tax", "Total Amount (Incl. Tax)","Date"]]
@purchase_scope.each do |object|
  total_tax = object.stocks.inject(0){|result, stock| result + stock.stock_taxes.inject(0){|data,stock_tax| data + stock_tax.tax_amount} }
  total_amount = object.stocks.inject(0){|result, stock| result + stock.price}
  data +=  [["#{object.id}", "#{object.purchase_order.name} (ID: #{object.purchase_order.id})","#{object.purchase_order.vendor.name}" ,"#{total_tax}","#{total_amount}","#{object.updated_at.strftime('%d-%^b-%Y, %I:%M %p')}"]] 
end
pdf.table data, {:header => false, :width => 550} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end