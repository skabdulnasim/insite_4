
xml.ENVELOPE do
  xml.HEADER do
    xml.TALLYREQUEST "Import Data"
  end
  xml.BODY do
    xml.IMPORTDATA do
      xml.REQUESTDATA do
        xml.TALLYMESSAGE("xmlns:UDF"=> "TallyUDF") do
          xml.VOUCHER("VCHTYPE"=>"SALES","ACTION"=>"Create") do

            cash_sale = 0
            card_sale = 0
            discount = 0
            service_tax = 0
            service_charge = 0
            product_sale = 0
            nc_void = 0

            xml.VOUCHERTYPENAME "SALES"
            xml.DATE @from_datetime.strftime('%Y%m%d')
            xml.EFFECTIVEDATE @from_datetime.strftime('%Y%m%d')
            xml.VOUCHERNUMBER "S-#{@outlet.unit_name}#{@from_datetime.strftime('%Y%m%d')}"
            xml.NARRATION "[Sales Posted From Stewot Software For the Outlet #{@outlet.unit_name} Dated. #{@from_datetime.strftime('%Y%m%d')}]"
            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Cash-in-Hand" #payment Mode Name 
              cash_sale = @settlement_data[:cash_sale]
              xml.AMOUNT "-#{cash_sale}" #Total Amount as Negetive 
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Sundry Debtors" #payment Mode Name 
              card_sale = @settlement_data[:card_sale]
              xml.AMOUNT "-#{card_sale}"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Service tax" #payment Mode Name 
              service_tax = Bill.tax_summery(@outlet.id,@from_datetime,@to_datetime,"SERVICE TAX @5.8%")[@from_datetime.strftime('%Y-%m-%d')]
              xml.AMOUNT  service_tax#Total Amount as Negetive 
            end
            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Discount" #payment Mode Name 
              discount = Bill.set_unit_in(@outlet.id).check_bill_date_range(@from_datetime,@to_datetime).sum(:discount)
              xml.AMOUNT "-#{discount}"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "NC Void" #payment Mode Name 
              nc_void = Bill.set_unit_in(@outlet.id).check_bill_date_range(@from_datetime,@to_datetime).where("status IN ('no_charge','void')").sum(:bill_amount)
              xml.AMOUNT "-#{nc_void}"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Service charge" #payment Mode Name 
              service_charge = Bill.tax_summery(@outlet.id,@from_datetime,@to_datetime,"SERVICE CHARGE @10%")[@from_datetime.strftime('%Y-%m-%d')]
              xml.AMOUNT  service_charge#Total Amount as Negetive 
            end

            #order_id_for_bill = Bill.valid_bill.check_bill_date_range(@from_datetime,@to_datetime).map{|bill| bill.orders.map{|order| order.id}}.flatten;
            
            order_id_for_bill = Bill.check_bill_date_range(@from_datetime,@to_datetime).map{|bill| bill.orders.map{|order| order.id}}.flatten;
            
            MenuCard.find(8).menu_categories.where(:parent => nil).each do |data| 
              xml.tag! ("ALLLEDGERENTRIES.LIST") do
                xml.ISDEEMEDPOSITIVE "NO"
                xml.LEDGERNAME data.name
                #xml.AMOUNT OrderDetail.set_unit(current_user.unit_id).by_date_range(@from_datetime,@to_datetime).sum(:unit_price_without_tax)
                 sale = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
                 product_sale = product_sale + sale.to_f
                 xml.AMOUNT sale
              end
            end

            round_off = (cash_sale.to_f + card_sale.to_f + discount.to_f + nc_void.to_f) - (product_sale.to_f + service_charge.to_f + service_tax.to_f)

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE round_off < 0 ? "YES" : "NO"
              xml.LEDGERNAME "Roff " #payment Mode Name 
              xml.AMOUNT  round_off.round(2)#Total Amount as Negetive 
            end
          end
        end
      end
    end
  end
end
