require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  
  pdf.text_box "STORE ID = " "#{@store.id}", :at => [5,40], :size => 10
  pdf.text_box "To Date: #{params[:to_date]}",   :at => [500,60]
  pdf.text_box "From Date: #{params[:from_date]}", :at => [490,70]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end

data = [["Transfer ID", "Reference", "Products", "Total Amount", "To Store", "Date"]]
@stock_issue_scope.each do |object|
 _products = "#{object.stocks.type_debit.map{|stock| stock.product.name + stock.stock_debit.to_s + stock.product.basic_unit}.join(" | ")}"
 _ref = object.store_requisition_log_id.present? ? "Requisition ID: #{object.store_requisition_log_id}" : ""
 data += [["#{object.id}", "#{_ref}", "#{_products}", "#{object.stocks.set_store(object.primary_store_id).sum(:price)}","#{object.to_store.name} (Branch: #{object.to_store.unit.unit_name})", "#{object.created_at.strftime('%d-%^b-%Y, %I:%M %p')}"]]
end

pdf.table data, {:header => false, :width => 550} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end