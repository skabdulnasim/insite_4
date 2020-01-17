xml.ENVELOPE do
  xml.HEADER do
    xml.TALLYREQUEST "IMPORT DATA"
  end
  xml.BODY do
    xml.IMPORTDATA do
      xml.REQUESTDATA do
        xml.TALLYMESSAGE('xmlns:UDF'=>"TALLYUDF") do 
        	xml.VOUCHER("VCHTYPE"=>"SALES","ACTION"=>"CREATE") do
        		xml.VOUCHERTYPENAME "SALES"
        		xml.DATE @from_datetime.strftime('%Y%m%d')
        		xml.EFFECTIVEDATE @from_datetime.strftime('%Y%m%d')
        		xml.VOUCHERNUMBER "S-#{@from_datetime.strftime('%Y%m%d')}"
        		xml.NARRATION "[SALES POSTED FROM INSITES]DATED. #{@from_datetime.strftime('%Y%m%d')}"

        		xml.tag! ("ALLLEDGERENTRIES.LIST") do
        			xml.ISDEEMEDPOSITIVE "YES"
        			xml.LEDGERNAME "Sundry Debtors"
        			xml.AMOUNT "-2913582.21"
        		end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Carry Forward"
              xml.AMOUNT "-2202293.66"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Credit Card"
              xml.AMOUNT "-563859.58"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Cash Collection"
              xml.AMOUNT "-331112.74"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Sundry Debtors"
              xml.AMOUNT "-39526.98"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Advance Cash"
              xml.AMOUNT "-36016.94"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Cheque Collection"
              xml.AMOUNT "-29500"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "YES"
              xml.LEDGERNAME "Local Calls"
              xml.AMOUNT "-20"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "HCS Health Club"
              xml.AMOUNT "500"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "KLS Indian Liquor"
              xml.AMOUNT "800"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "PAS Food & Beverages"
              xml.AMOUNT "800"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "MYT Soft Drinks"
              xml.AMOUNT "967.5"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "VIR Cigarette"
              xml.AMOUNT "1050"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "TRV Travel Desk"
              xml.AMOUNT "1714.28"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "RS1 Soft Drinks"
              xml.AMOUNT "1825"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "VIR Food & Beverages"
              xml.AMOUNT "2363.5"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "KLS Soft Drinks"
              xml.AMOUNT "3275"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "VIR Soft Drinks"
              xml.AMOUNT "3760"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "CESS"
              xml.AMOUNT "4954.8"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "STH Miscellaneous Receipt"
              xml.AMOUNT "5423.7"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "UNG Cigarette"
              xml.AMOUNT "5950"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "MYT Foreign Liquor"
              xml.AMOUNT "6100"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "KLS Foreign Liquor"
              xml.AMOUNT "6500"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "LAN LAUNDRY"
              xml.AMOUNT "6760"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "VAL Health Club"
              xml.AMOUNT "11648.32"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "UNG Soft Drinks"
              xml.AMOUNT "12910"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "VIR Foreign Liquor"
              xml.AMOUNT "17005"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "UNG Food & Beverages"
              xml.AMOUNT "17080.75"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "KLS Food & Beverages"
              xml.AMOUNT "19815"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Paid Out"
              xml.AMOUNT "22159.52"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "BQS HALL RENTAL"
              xml.AMOUNT "25000"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "MYT Indian Liquor"
              xml.AMOUNT "25805"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "VIR Indian Liquor"
              xml.AMOUNT "26557.5"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "MYT Food & Beverages"
              xml.AMOUNT "30109.84"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "RS1 Food & Beverages"
              xml.AMOUNT "30890.84"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Central Gst Tax"
              xml.AMOUNT "107871.72"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "State Gst Tax"
              xml.AMOUNT "107871.72"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "UNG Indian Liquor"
              xml.AMOUNT "158288.9"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "BQS Food & Beverages"
              xml.AMOUNT "300640"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "UNG Foreign Liquor"
              xml.AMOUNT "329005"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Room Sales"
              xml.AMOUNT "710250.77"
            end

            xml.tag! ("ALLLEDGERENTRIES.LIST") do
              xml.ISDEEMEDPOSITIVE "NO"
              xml.LEDGERNAME "Brought Forward"
              xml.AMOUNT "4123856.35"
            end

        		xml.tag! ("ALLLEDGERENTRIES.LIST") do
        			xml.ISDEEMEDPOSITIVE "YES"
        			xml.LEDGERNAME "SUSPENSE ENTRY"
        			xml.AMOUNT "-13597.9"
        		end

        	end
        end
      end
    end
  end
end