require "prawn/table"
pdf.font_size 8

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  pdf.text_box "#{@bill.orders[0].unit.unit_name}", :at => [5,50], :size => 16
  pdf.text_box "Date : #{Time.now.strftime("%d %b %Y, %I:%M %p")}", :at => [440,50]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end

pdf.text "Bill ID: #{@bill.id}", :size => 16

data = [["# Order Id", "Item", "Qty", "Price", "Customization Price", "Subtotal"]]
subtotal = 0
@bill.orders.each do |bill_order|
  get_order_details_from_order(bill_order.id).each do |order_details|
    _subtotal_without_tax = MenuManagement::get_menu_product_details_by_id(order_details.menu_product_id).sell_price_without_tax * order_details.quantity 

    _combo_price = order_details.order_detail_combinations.sum(:total_price).presence || 0

    data += [["# #{bill_order.id}", "#{order_details.menu_product.product.name}", "#{order_details.quantity} #{order_details.menu_product.product.basic_unit}",  "#{_subtotal_without_tax}", "#{_combo_price}", "#{_subtotal_without_tax + _combo_price}"]]
  end
end
data += [["", "", "",  "", "Bill Amount", "#{@bill.bill_amount}"]]
data += [["", "", "",  "", "Tax Amount", "(+) #{@bill.tax_amount}"]]
data += [["", "", "",  "", "Discount", "(-) #{@bill.discount}"]]
data += [["", "", "",  "", "Roundoff", "#{@bill.roundoff}"]]
data += [["", "", "",  "", "Grand Total", "#{@bill.grand_total}"]]
pdf.table data, {:header => true, :width => 550, :column_widths => [50,150,75,75,100,100]} do |table|
  table.header=(["Header1", "Header2", "Header3", "Header4", "Header5", "Header6"])     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end