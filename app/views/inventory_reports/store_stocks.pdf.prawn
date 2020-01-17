require "prawn/table"
pdf.font_size 6

pdf.bounding_box([pdf.bounds.right - 550,pdf.bounds.top], :width => 560, :height => 50, :font_size  => 14) do
  
  pdf.text_box "STORE ID = " "#{@store.id}", :at => [5,40], :size => 10
  pdf.text_box "Date: #{params[:from_date]}", :at => [500,70]
  pdf.move_down 20 
  pdf.stroke do
    pdf.stroke_color 'EEEEEE'
    pdf.line_width 2
    pdf.stroke_horizontal_rule
  end   
end 
preferences = ReportPreference.by_unit(current_user.unit_id).by_key('stock_summery_report_store_wise').first
@pref = preferences.present? ? JSON.parse(preferences.allowed_attributes) : ["product","opening_stock","stock_on_aduit","consumed_for_audit","audit_cost","consumed_for_order","order_cost","consumed_for_transfer","transfer_cost","total_debit","debit_cost","stock_purchase","purchase_cost","total_credit","credit_cost","closing_stock","current_stock","stock_value"]
pdf_header = Array.new
pdf_header.push("Product") if @pref.include?('product')
pdf_header.push("Opening Stock") if @pref.include?('opening_stock')  
pdf_header.push("Consumed (Audits)") if @pref.include?('consumed_for_audit')        
pdf_header.push("Cost of Audit (#{currency})") if @pref.include?('audit_cost')     
pdf_header.push("Consumed (Orders)") if @pref.include?('consumed_for_order')            
pdf_header.push("Cost of Order (#{currency})") if @pref.include?('order_cost')    
pdf_header.push("Consumed (Transfers)") if @pref.include?('consumed_for_transfer')          
pdf_header.push("Cost of Transfers (#{currency})") if @pref.include?('transfer_cost')      
pdf_header.push("Total Debit") if @pref.include?('total_debit')          
pdf_header.push("Cost of Debit (#{currency})") if @pref.include?('debit_cost')    
pdf_header.push("Stock Purchases") if @pref.include?('stock_purchase')    
pdf_header.push("Cost of Purchase (#{currency})") if @pref.include?('purchase_cost')    
pdf_header.push("Total Credit") if @pref.include?('total_credit')  
pdf_header.push("Cost of Credit (#{currency})") if @pref.include?('credit_cost')     
pdf_header.push("Closing Stock") if @pref.include?('closing_stock')     
pdf_header.push("Current Stock") if @pref.include?('current_stock')  
pdf_header.push("Value of Stock (#{currency})") if @pref.include?('stock_value')  
data = [pdf_header]
  @pro_scope.each do |product|
  sd = Stock.get_stock_report(@store_id, product.id, @from_datetime, @to_datetime)
  cs = StockUpdate.current_stock(@store_id, product.id)
  current_stock_price = sd[:current_stock_price].to_i
  pdf_product = Array.new
  pdf_product.push(product.name) if @pref.include?('product')
  pdf_product.push(sd[:opening_stock]) if @pref.include?('opening_stock')  
  pdf_product.push(sd[:audit_consumption]) if @pref.include?('consumed_for_audit')        
  pdf_product.push(sd[:audit_consumption_price].to_f.round(2)) if @pref.include?('audit_cost')     
  pdf_product.push(sd[:order_consumption]) if @pref.include?('consumed_for_order')            
  pdf_product.push(sd[:order_consumption_price].to_f.round(2)) if @pref.include?('order_cost')    
  pdf_product.push(sd[:transfer_consumption]) if @pref.include?('consumed_for_transfer')          
  pdf_product.push(sd[:transfer_consumption_price].to_f.round(2)) if @pref.include?('transfer_cost')      
  pdf_product.push(sd[:total_debit]) if @pref.include?('total_debit')          
  pdf_product.push(sd[:total_debit_price].to_f.round(2)) if @pref.include?('debit_cost')    
  pdf_product.push(sd[:total_purchase]) if @pref.include?('stock_purchase')    
  pdf_product.push(sd[:total_purchase_price].to_f.round(2)) if @pref.include?('purchase_cost')    
  pdf_product.push(sd[:total_credit]) if @pref.include?('total_credit')  
  pdf_product.push(sd[:total_credit_price].to_f.round(2)) if @pref.include?('credit_cost')     
  pdf_product.push(sd[:closing_stock]) if @pref.include?('closing_stock')     
  pdf_product.push(cs) if @pref.include?('current_stock')  
  pdf_product.push(current_stock_price) if @pref.include?('stock_value') 
  data += [pdf_product]
end
column_widths = Array.new
column_widths.push(50) if @pref.include?('product')
column_widths.push(30) if @pref.include?('opening_stock')  
column_widths.push(30) if @pref.include?('consumed_for_audit')        
column_widths.push(30) if @pref.include?('audit_cost')     
column_widths.push(30) if @pref.include?('consumed_for_order')            
column_widths.push(30) if @pref.include?('order_cost')    
column_widths.push(30) if @pref.include?('consumed_for_transfer')          
column_widths.push(32) if @pref.include?('transfer_cost')      
column_widths.push(32) if @pref.include?('total_debit')          
column_widths.push(32) if @pref.include?('debit_cost')    
column_widths.push(32) if @pref.include?('stock_purchase')    
column_widths.push(32) if @pref.include?('purchase_cost')    
column_widths.push(32) if @pref.include?('total_credit')  
column_widths.push(32) if @pref.include?('credit_cost')     
column_widths.push(32) if @pref.include?('closing_stock')     
column_widths.push(32) if @pref.include?('current_stock')  
column_widths.push(32) if @pref.include?('stock_value')
width = column_widths.inject(0){|sum,x| sum + x }
  
pdf.table data, {:header => true, :width => width, :column_widths => column_widths} do |table|
table_header = Array.new
table_header.push("Header1") if @pref.include?('product')
table_header.push("Header2") if @pref.include?('opening_stock')  
table_header.push("Header3") if @pref.include?('consumed_for_audit')        
table_header.push("Header4") if @pref.include?('audit_cost')     
table_header.push("Header5") if @pref.include?('consumed_for_order')            
table_header.push("Header6") if @pref.include?('order_cost')    
table_header.push("Header7") if @pref.include?('consumed_for_transfer')          
table_header.push("Header8") if @pref.include?('transfer_cost')      
table_header.push("Header9") if @pref.include?('total_debit')          
table_header.push("Header10") if @pref.include?('debit_cost')    
table_header.push("Header11") if @pref.include?('stock_purchase')    
table_header.push("Header12") if @pref.include?('purchase_cost')    
table_header.push("Header13") if @pref.include?('total_credit')  
table_header.push("Header14") if @pref.include?('credit_cost')     
table_header.push("Header15") if @pref.include?('closing_stock')     
table_header.push("Header16") if @pref.include?('current_stock')  
table_header.push("Header17") if @pref.include?('stock_value')
  table.header=(table_header)     
  table.row(0).font_style = :bold
  table.cells.borders = [:top]
  table.cells.row(0).background_color = 'cccccc'
  table.cells.row(-1).background_color = 'cccccc'
end