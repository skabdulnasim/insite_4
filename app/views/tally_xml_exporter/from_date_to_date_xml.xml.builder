xml.ENVELOPE do
  xml.HEADER do
    xml.TALLYREQUEST "Import Data"
  end
  xml.BODY do
    xml.IMPORTDATA do
      xml.REQUESTDESC do
        xml.REPORTNAME "VOUCHER" 
        xml.SVCURRENTCOMPANY "Annapurna Sweets Pvt. Ltd. (2018-19)"
      end  
      xml.REQUESTDATA do
        xml.TALLYMESSAGE("xmlns:UDF"=> "TallyUDF") do
          xml.VOUCHER("VCHTYPE"=>"SALES","ACTION"=>"Create") do
            xml.ISOPTIONAL "No"
            xml.USEFORGAINLOSS "No"
            xml.USEFORCOMPOUND "No"

            cash_sale = 0
            card_sale = 0
            nonta_sale = 0
            notta_quentity = 0
            nonta_product_sale = 0
            nonta_product_quentity = 0
            sweet_sale = 0
            sweet_quentity = 0
            sweet_product_sale = 0
            sweet_product_quentity = 0

            xml.VOUCHERTYPENAME "SALES"
            xml.DATE @from_datetime.strftime('%Y%m%d')
            xml.EFFECTIVEDATE @from_datetime.strftime('%Y%m%d')
            xml.ISCANCELLED "No"
            xml.USETRACKINGNUMBER "No"
            xml.ISPOSTDATED "No"
            xml.ISINVOICE "Yes"
            xml.DIFFACTUALQTY "NO"
            xml.PARTYNAME "Cash"
            xml.PARTYLEDGERNAME "Cash"
            xml.NARRATION "being the cash received against sale."
            xml.ASPAYSLIP "No"
            #xml.GUID "78af428e-22ef-4175-ac69-5e9882a6dccc-0000008a"
            #xml.ALTERID '256'
            #xml.VOUCHERNUMBER "S-#{@outlet.unit_name}#{@from_datetime.strftime('%Y%m%d')}"
            #xml.NARRATION "[Sales Posted From Stewot Software For the Outlet #{@outlet.unit_name} Dated. #{@from_datetime.strftime('%Y%m%d')}]"
            xml.tag! ("LEDGERENTRIES.LIST") do
              xml.REMOVEZEROENTRIES "No"
              xml.ISDEEMEDPOSITIVE "Yes" 
              xml.LEDGERFROMITEM "No" 
              xml.LEDGERNAME "Cash"  #payment Mode Name
              cash_sale = @settlement_data[:cash_sale]
              xml.AMOUNT "-#{cash_sale}" #Total Amount as Negetive 
            end

            order_id_for_bill = Bill.check_bill_date_range(@from_datetime,@to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten;
            @menu_card.menu_categories.where(:parent => nil).each do |data| 
              puts data.name.humanize
              if data.name.humanize == "Nonta"
                nonta_sale              = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
                notta_quentity          = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("quantity")
                nonta_product_sale      = nonta_product_sale + nonta_sale.to_f
                nonta_product_quentity  = nonta_product_quentity + notta_quentity.to_f
              elsif data.name.humanize != "Nonta"
                sweet_sale              = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("unit_price_without_tax * quantity")
                sweet_quentity          = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.submenucategories.map{|category| category.menu_products.map{|product| product.id}}.flatten).sum("quantity")
                sweet_product_sale      = sweet_product_sale + sweet_sale.to_f
                sweet_product_quentity  = sweet_product_quentity + sweet_quentity.to_f
              end  
            end

            xml.tag! ("ALLINVENTORYENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.STOCKITEMNAME "Sweets"
              xml.AMOUNT sweet_product_sale.to_f
              xml.ACTUALQTY "#{sweet_product_quentity}" " Pc" 
              xml.BILLEDQTY "#{sweet_product_quentity}" " Pc" 
              xml.RATE "#{(sweet_product_sale.to_f / sweet_product_quentity.to_f).round(2)}" "/Pc"
            end

            xml.tag! ("ACCOUNTINGALLOCATIONS.LIST") do
              xml.REMOVEZEROENTRIES "NO"
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERFROMITEM "No"
              xml.LEDGERNAME "Sales" 
              xml.AMOUNT "#{sweet_product_sale.to_f}"
              xml.tag! ("BATCHALLOCATIONS.LIST") do
                xml.BATCHNAME "Primary Batch"
                xml.GODOWNNAME "#{@unit.unit_name}"
                xml.MFDON "#{@from_datetime.strftime('%Y%m%d')}"
                xml.AMOUNT "#{sweet_product_sale.to_f}"
                xml.ACTUALQTY "#{sweet_product_quentity}" " Pc" 
                xml.BILLEDQTY "#{sweet_product_quentity}" " Pc" 
              end
            end

            xml.tag! ("ALLINVENTORYENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Snacks"
              xml.AMOUNT nonta_product_sale.to_f
              xml.ACTUALQTY "#{nonta_product_quentity}" " Pc" 
              xml.BILLEDQTY "#{nonta_product_quentity}" " Pc" 
              xml.RATE "#{(nonta_product_sale.to_f / nonta_product_quentity.to_f).round(2)}" "/Pc"
            end

            xml.tag! ("ACCOUNTINGALLOCATIONS.LIST") do
              xml.REMOVEZEROENTRIES "NO"
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERFROMITEM "No"
              xml.LEDGERNAME "Sales" 
              xml.AMOUNT "#{nonta_product_sale.to_f}"
              xml.tag! ("BATCHALLOCATIONS.LIST") do
                xml.BATCHNAME "Primary Batch"
                xml.GODOWNNAME "#{@unit.unit_name}"
                xml.MFDON "#{@from_datetime.strftime('%Y%m%d')}"
                xml.AMOUNT "#{nonta_product_sale.to_f}"
                xml.ACTUALQTY "#{nonta_product_quentity}" " Pc" 
                xml.BILLEDQTY "#{nonta_product_quentity}" " Pc" 
              end
            end

          end
        end
      end
    end
  end
end