require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size => 14) do  
	_header_text = @unit.unit_detail.present? ? @unit.unit_detail.options[:bill_header_text] : @unit.unit_name
	pdf.text_box "#{_header_text}", :at => [5,70], :size => 10
	pdf.text_box "Date: #{params[:from_date]}", :at => [500, 70]
	pdf.move_down 200
	pdf.stroke do
		pdf.stroke_color 'EEEEEE'
		pdf.line_width 2
		pdf.stroke_horizontal_rule
	end
end
_pref = ["bill id","product name","price","quantity","sku","Total Price","customer name","remarks","added_to_stock"]
_pref_humanize =  _pref.map{|x| (x.humanize)}
data = [_pref_humanize]
@return_items.each do |return_item|
	_row = Array.new
	_row.push(return_item.bill_id)
	_row.push(return_item.product.name)
	_row.push(return_item.price)
	_row.push(return_item.quantity)
	_row.push(return_item.sku.present? ? "#{return_item.sku}" : "_")
	_row.push(return_item.price.to_f * return_item.quantity.to_f)
	if return_item.bill.customer.present?
		if return_item.bill.customer.customer_profile.customer_name.present?
			_row.push(return_item.bill.customer.customer_profile.customer_name)
		else
			_row.push("#{return_item.bill.customer.customer_profile.firstname} "" #{return_item.bill.customer.customer_profile.lastname}")
		end	
	else
		_row.push("....")	
	end
	_row.push(return_item.remarks)
	_row.push(return_item.added_to_stock.present? ? "true" : "false") 
	data += [_row]
end
pdf.table data, {:header => false, :width => 540} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  # table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end



