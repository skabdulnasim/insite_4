require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  _header_text = @store.name
  pdf.text_box "#{_header_text}", :at => [5,70], :size => 10
  pdf.text_box "Requisition summary", :at => [6,50], :size => 10
  pdf.text_box "Date: #{@rq_date}",   :at => [500,60]
  pdf.move_down 200 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
pdf_data = [["Product","From Store","Requisitions Amount","Current Stock"]]
@summary_requisitions.each  do |product_id,data|
  requisition_meta_details = LogItem.set_product_in(product_id).na_requisitions.store_requistion(@store.id).by_created_at(@rq_date) 

  _row = Array.new
  product = Product.find(product_id)
  stock = number_with_precision(get_product_current_stock(@store.id, product_id), :precision => 8, :significant => true, :strip_insignificant_zeros => true)
  _row.push(product.name) 
  _row.push('_')
  _row.push("#{data['total_amount']} #{product.basic_unit}")
  _row.push("#{stock} #{product.basic_unit}") 
  pdf_data += [_row] # Pushing row to PDF table
  requisition_meta_details.each do |requisition_meta|
    store = Store.find(requisition_meta.from_store_id)
    _pdf_requisition_meta = Array.new
    _pdf_requisition_meta.push('_')
    _pdf_requisition_meta.push("#{store.name}" " (Branch: #{store.unit.unit_name})")
    _pdf_requisition_meta.push("#{requisition_meta.product_ammount} #{product.basic_unit}")
    _pdf_requisition_meta.push('_')
    pdf_data += [_pdf_requisition_meta] # Pushing row to PDF table
  end
end 
pdf.table pdf_data, {:header => true, :width => 550, :column_widths => [200,200,100,50]} do |table|
  table.header=(["Header1", "Header2", "Header3"])     
  table.row(0).font_style = :bold
end
