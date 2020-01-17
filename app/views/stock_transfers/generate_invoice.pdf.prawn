require "prawn/table"
pdf.font_size 8

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  pdf.text_box "#{@account}", :at => [5,50], :size => 16
  pdf.text_box "Date : #{@stock_transfer.created_at.strftime("%d %b %Y, %I:%M %p")}", :at => [440,50]
  pdf.move_down 20
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end
end

pdf.bounding_box([0,680], :width => 200) do
  pdf.text("From")
  pdf.text("#{@stock_transfer.from_store.name}")
    pdf.text("#{@stock_transfer.from_store.address}")
    pdf.text("Pin Code : #{@stock_transfer.from_store.pincode}")
    pdf.text("Contact No : #{@stock_transfer.from_store.contact_number}")
end

pdf.bounding_box([200,680], :width => 200) do
  pdf.text("To")
  pdf.text("#{@stock_transfer.to_store.name}")
    pdf.text("#{@stock_transfer.to_store.address}")
    pdf.text("Pin Code : #{@stock_transfer.to_store.pincode}")
    pdf.text("Contact No : #{@stock_transfer.to_store.contact_number}")
end

pdf.bounding_box([410,680], :width => 140) do
  pdf.text("Transaction Id # #{@stock_transfer.id}")
  pdf.text("Payment Due: #{@stock_transfer.created_at.strftime("%d %b %Y, %I:%M %p")}")
    #pdf.text("Account: 968-34567")
end

pdf.move_down 50
data = [["Product", "Qty", "Item Price", "Tax Amount", "Subtotal"]]
subtotal = 0
taxtotal = 0
grandtotal = 0
if @stock_transfer.stock_transfer_meta.present?
  @stock_transfer.stock_transfer_meta.each do |inv|
    _product = inv.sku.present? ? "#{inv.product_id} # #{inv.product.name} - (#{inv.sku})" : "#{inv.product_id} # #{inv.product.name}"
    if inv.transferable?
      data += [[_product, "#{inv.quantity_transfered} #{inv.product.basic_unit}",  "#{inv.price_without_tax}", "#{inv.tax_amount}", "#{inv.price_with_tax}"]]
      subtotal += inv.price_without_tax
      taxtotal += inv.tax_amount
      grandtotal += inv.price_with_tax
    end
  end
else
  @stock_transfer.stock_transfer_invoice.stock_transfer_invoice_meta.each do |inv|
    data += [["#{inv.product_id} # #{inv.product.name}", "#{inv.quantity} #{inv.product.basic_unit}",  "#{inv.price}", "#{inv.tax_group_id.present? ? inv.tax_amount : 0}", "#{inv.tax_group_id.present? ? inv.price_with_tax : inv.price}"]]
    subtotal = subtotal.to_i + inv.price
    taxtotal += inv.tax_group_id.present? ? inv.tax_amount : 0
  end
end
pdf.table data, {:header => true, :width => 550, :column_widths => [200,50,100,100,100]} do |table|
    table.header=(["Header1", "Header2", "Header3", "Header4", "Header5"])
    table.row(0).font_style = :bold
end

invoiceinfo = [["Subtotal", number_to_currency("#{subtotal}", unit: currency, format: "%u %n")], ["Tax", number_to_currency("#{taxtotal}", unit: currency, format: "%u %n")],["Shipping", number_to_currency(0, unit: currency, format: "%u %n")], ["Total", number_to_currency("#{grandtotal}", unit: currency, format: "%u %n")]]

pdf.move_down 30
pdf.table invoiceinfo, :width => 250

pdf.move_down 20

pdf.text "Signature : ___________________________", :align => :right

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.bottom], :width => 560, :height => 50, :font_size  => 14) do
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end
end
