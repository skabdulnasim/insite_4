require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  _header_text = @unit.unit_detail.present? ? @unit.unit_detail.options[:bill_header_text] : @unit.unit_name
  pdf.text_box "#{_header_text}", :at => [5,70], :size => 10
  pdf.text_box "Sales Report by Category", :at => [150,50], :size => 20
  pdf.text_box "To Date: #{params[:to_date]}",   :at => [500,60]
  pdf.text_box "From Date: #{params[:from_date]}", :at => [490,70]
  pdf.move_down 20
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end
lata = [[ "Main Category","Sub Category",'Product','SKU','Quantity','Sale(Without Tax)','Tax']]
 @category_sales.each do |main_cat,data|
   lata += [[main_cat,'','','','',data['sale'],data['tax']]]
   data["children"].each do |sub_cat_data|
    lata += [['',sub_cat_data.keys.first,'','','',sub_cat_data[sub_cat_data.keys.first]["sale"],sub_cat_data[sub_cat_data.keys.first]["tax"]]]
    sub_cat_data[sub_cat_data.keys.first]["products"].each do |product|
     lata += [['','',product.menu_product.product.name,product.product_unique_identity,product.quantity,product.total_sale,product.pro_tax]]
    end
  end
end
pdf.table lata, {:header => true, :width => 550, :column_widths => [50,100,100,100,50,50,100]} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6","Header7"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end