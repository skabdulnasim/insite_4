xml.ENVELOPE do
  xml.HEADER do
    xml.TALLYREQUEST "IMPORT DATA"
  end
  xml.BODY do
    xml.IMPORTDATA do
      xml.REQUESTDATA do
        xml.TALLYMESSAGE('xmlns:UDF'=>"TALLYUDF") do 
        	xml.VOUCHER("VCHTYPE"=>"JOURNAL","ACTION"=>"CREATE") do
        		xml.VOUCHERTYPENAME "JOURNAL"
        		xml.DATE "20190601"
        		xml.EFFECTIVEDATE "20190601"
        		xml.VOUCHERNUMBER "J-20190601"
        		xml.NARRATION "[SALES JOURNAL POSTED FROM IDS SOFTWARE]DATED. 20190601"

        		xml.tag! ("ALLLEDGERENTRIES.LIST") do
        			xml.ISDEEMEDPOSITIVE "YES"
        			xml.LEDGERNAME "CARD - HDFC BANK"
        			xml.AMOUNT "-1000"
              xml.tag! ("BILLALLOCATIONS.LIST") do
                xml.NAME "1912/190601-1-"
                xml.BILLTYPE "NEW REF"
                xml.AMOUNT "-1000"
              end
        		end

        		xml.tag! ("ALLLEDGERENTRIES.LIST") do
        			xml.ISDEEMEDPOSITIVE "NO"
        			xml.LEDGERNAME "BANQUET BOOKING"
        			xml.AMOUNT "8500"
        		end

        	end
        end
      end
    end
  end
end