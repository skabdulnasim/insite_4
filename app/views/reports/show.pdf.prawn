require "prawn/table"
pdf.font_size 8

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  pdf.text_box "#{@account}".humanize, :at => [5,50], :size => 16
  pdf.text_box "Date : #{Time.now.strftime("%d %b %Y, %I:%M %p")}", :at => [440,50]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
  
end


pdf.bounding_box([0,680], :width => 200) do
  pdf.text_box "#{@report.name}".humanize, :size => 16
end

pdf.bounding_box([400,680], :width => 470) do
  pdf.text_box "#{@report.report_criteria}".humanize, :size => 10
end



 

attr_names = @report_data.first.attribute_names
arr = Array.new
attr_names.each do |attr_name|
  arr.push attr_name.humanize
end

data = [arr]

@report_data.each do |entry|
  final_arr = Array.new
  attr_names.each do |key|
    final_arr.push entry[key]
    puts final_arr
  end
  data += [final_arr] 
end


pdf.move_down 50
pdf.table data, {:header => true, :width => 550} do |table|
  table.row(0).font_style = :bold
end
