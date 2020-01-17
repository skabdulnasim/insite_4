require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  
  pdf.text_box "Stock Pruchase Summary Report", :at => [5,40], :size => 10
  pdf.text_box "To Date: #{params[:to_date]}",   :at => [500,60]
  pdf.text_box "From Date: #{params[:from_date]}", :at => [490,70]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end

data = [["Store", "Unit","Purchase Cost"]]
summary_price = 0
@puchase_stock.each do |object|
  summary_price = summary_price + object.total_price.to_f
  data += [["#{object.store.name}", "#{object.store.unit.unit_name}", "#{object.total_price}"]]
end
  summary = [["Total", "-", "#{summary_price}"]]
pdf.table data, {:header => false, :width => 550} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6","Header7"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
end
pdf.table summary, {:header => false, :width => 550} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6","Header7"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(-1).background_color = 'cccccc'
end