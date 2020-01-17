
xml.ENVELOPE do
  xml.HEADER do
    xml.TALLYREQUEST "Import Data"
  end
  xml.BODY do
    xml.IMPORTDATA do
      xml.REQUESTDATA do

        @stores.each do |store|
          store.stock_purchases.received.date_range(@from_datetime,@to_datetime).each do |stock_purchase|
            xml.TALLYMESSAGE("xmlns:UDF"=> "TallyUDF") do
              xml.VOUCHER("VCHTYPE"=>"Purchase","ACTION"=>"Create") do
                xml.VOUCHERTYPENAME "Purchase"
                xml.DATE stock_purchase.updated_at.strftime('%Y%m%d')
                xml.VOUCHERNUMBER "#{store.name}-#{stock_purchase.id}"
                xml.REFERENCE stock_purchase.purchase_order.id
                xml.NARRATION "GRN# #{stock_purchase.id} Dt: #{stock_purchase.updated_at.strftime('%d-%^b-%Y')} #{stock_purchase.stocks.map{|stock| stock.product.name + stock.stock_credit.to_s + stock.product.basic_unit}.join(" ")}"
                total_price = stock_purchase.stocks.inject(0){|result, stock| result + stock.price}
                total_tax   = stock_purchase.stocks.inject(0){|result, stock| result + stock.stock_taxes.inject(0){|data,stock_tax| data + stock_tax.tax_amount} }
                #tax_names = stock_purchase.stocks.each{|stock| stock.stock_taxes.first.tax_class_name if stock.stock_taxes.first.present? } || ""
                xml.tag! ("ALLLEDGERENTRIES.LIST") do
                  xml.ISDEEMEDPOSITIVE "NO"
                  xml.LEDGERFROMITEM "YES" #payment Mode Name
                  xml.LEDGERNAME stock_purchase.purchase_order.vendor.name
                  xml.AMOUNT total_price
                  xml.tag! ("BILLALLOCATIONS.LIST") do
                    xml.NAME stock_purchase.purchase_order.id
                    xml.BILLTYPE "New Ref"
                    xml.AMOUNT total_price
                  end
                end
                xml.tag! ("ALLLEDGERENTRIES.LIST") do
                  xml.ISDEEMEDPOSITIVE "YES"
                  xml.LEDGERFROMITEM "YES" #payment Mode Name
                  xml.LEDGERNAME stock_purchase.purchase_order.name
                  xml.AMOUNT "-#{total_price - total_tax}"
                end
                xml.tag! ("ALLLEDGERENTRIES.LIST") do
                  xml.ISDEEMEDPOSITIVE "YES"
                  xml.LEDGERFROMITEM "YES" #payment Mode Name
                  xml.LEDGERNAME "VAT 1"
                  xml.AMOUNT "-#{total_price - total_tax}"
                end
              end
            end
          end
        end
      end
    end
  end
end
##{stock_purchase.stocks.inject(0){|result, stock| result + stock.product.name}}