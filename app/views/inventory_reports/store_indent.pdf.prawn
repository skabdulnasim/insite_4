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

data = [["Requisition ID", "Reference", "Products", "From Store", "Date"]]
@requisition_scope.each do |object|
  _products = "#{object.store_requisition.store_requisition_metum.map{|meta| meta.product.name + meta.product_ammount.to_s + meta.product.basic_unit}.join(" | ")}" 
  #_status = self.get_requisition_status object
  data += [["#{object.id}", "#{object.store_requisition.name} (ID: #{object.store_requisition_id})", "#{_products}", "#{object.from_store.name} (Branch: #{object.from_store.unit.unit_name})", "#{object.created_at.strftime('%d-%^b-%Y, %I:%M %p')}"]]
end

pdf.table data, {:header => false, :width => 550} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end