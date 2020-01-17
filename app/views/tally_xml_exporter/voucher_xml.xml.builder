xml.ENVELOPE do
  xml.HEADER do
    xml.TALLYREQUEST "Import Data"
  end
  xml.BODY do
    xml.IMPORTDATA do
      xml.REQUESTDESC do
        xml.REPORTNAME "Vouchers" 
        xml.STATICVARIABLES do
        	xml.SVCURRENTCOMPANY AppConfiguration.get_config('tally_company_name')
        end
      end
      xml.REQUESTDATA do
        xml.TALLYMESSAGE('xmlns:UDF'=>"TallyUDF") do 
        	xml.VOUCHER("REMOTEID"=>"78af428e-22ef-4175-ac69-5e9882a6dccc-#{@from_datetime.strftime('%d%m%Y')}#{@unit.id}","VCHKEY"=>"78af428e-22ef-4175-ac69-5e9882a6dccc-0000a752:00000078","VCHTYPE"=>"Sales","ACTION"=>"Create","OBJVIEW"=>"Invoice Voucher View") do
        		xml.tag!("OLDAUDITENTRYIDS.LIST", "TYPE"=>"Number") do
        			xml.OLDAUDITENTRYIDS "-1"
        		end
        		xml.DATE @from_datetime.strftime('%Y%m%d')
        		xml.GUID "78af428e-22ef-4175-ac69-5e9882a6dccc-#{@from_datetime.strftime('%d%m%Y')}#{@unit.id}"
        		# xml.STATENAME "West Bengal"
        		# xml.GSTREGISTRATIONTYPE "Consumer"
        		# xml.VATDEALERTYPE "Unregistered"
        		xml.NARRATION "being the cash received against sale."
        		# xml.COUNTRYOFRESIDENCE "India"
        		xml.PARTYNAME "Cash"
        		xml.VOUCHERTYPENAME "Sales"
        		xml.VOUCHERNUMBER "57"
        		xml.PARTYLEDGERNAME "Cash"
        		xml.BASICBASEPARTYNAME "Cash"
        		xml.CSTFORMISSUETYPE
        		xml.CSTFORMRECVTYPE
        		xml.FBTPAYMENTTYPE "Default"
        		xml.PERSISTEDVIEW "Invoice Voucher View"
        		# xml.PLACEOFSUPPLY "West Bengal"
        		xml.BASICBUYERNAME "Cash"
        		xml.BASICDATETIMEOFINVOICE Time.now.strftime('%d-%b-%Y at %R')
        		xml.BASICDATETIMEOFREMOVAL Time.now.strftime('%d-%b-%Y at %R')
        		xml.VCHGSTCLASS
                xml.VOUCHERTYPEORIGNAME "Sales"
        		# xml.CONSIGNEESTATENAME "West Bengal"
        		xml.DIFFACTUALQTY "No"
        		xml.ISMSTFROMSYNC "No"
        		xml.ASORIGINAL "No"
        		xml.AUDITED "No"
        		xml.FORJOBCOSTING "No"
        		xml.ISOPTIONAL "No"
        		xml.EFFECTIVEDATE @from_datetime.strftime('%Y%m%d')
        		xml.USEFOREXCISE "No"
        		xml.ISFORJOBWORKIN "No"
        		xml.ALLOWCONSUMPTION "No"
        		xml.USEFORINTEREST "No"
        		xml.USEFORGAINLOSS "No"
        		xml.USEFORGODOWNTRANSFER "No"
        		xml.USEFORCOMPOUND "No"
        		xml.USEFORSERVICETAX "No"
        		xml.ISEXCISEVOUCHER "No"
        		xml.EXCISETAXOVERRIDE "No"
        		xml.USEFORTAXUNITTRANSFER "No"
        		xml.EXCISEOPENING "No"
        		xml.USEFORFINALPRODUCTION "No"
        		xml.ISTDSOVERRIDDEN "No"
        		xml.ISTCSOVERRIDDEN "No"
        		xml.ISTDSTCSCASHVCH "No"
        		xml.INCLUDEADVPYMTVCH "No"
        		xml.ISSUBWORKSCONTRACT "No"
        		xml.ISVATOVERRIDDEN "No"
        		xml.IGNOREORIGVCHDATE "No"
        		xml.ISVATPAIDATCUSTOMS "No"
        		xml.ISDECLAREDTOCUSTOMS "No"
        		xml.ISSERVICETAXOVERRIDDEN "No"
        		xml.ISISDVOUCHER "No"
        		xml.ISEXCISEOVERRIDDEN "No"
        		xml.ISEXCISESUPPLYVCH "No"
        		xml.ISGSTOVERRIDDEN "No"
        		xml.GSTNOTEXPORTED "No"
        		xml.ISVATPRINCIPALACCOUNT "No"
        		xml.ISBOENOTAPPLICABLE "No"
        		xml.ISSHIPPINGWITHINSTATE "No"
        		xml.ISOVERSEASTOURISTTRANS "No"
        		xml.ISCANCELLED "No"
        		xml.HASCASHFLOW "Yes"
        		xml.ISPOSTDATED "No"
        		xml.USETRACKINGNUMBER "No"
        		xml.ISINVOICE "Yes"
        		xml.MFGJOURNAL "No"
        		xml.HASDISCOUNTS "No"
        		xml.ASPAYSLIP "No"
        		xml.ISCOSTCENTRE "No"
        		xml.ISSTXNONREALIZEDVCH "No"
        		xml.ISEXCISEMANUFACTURERON "No"
        		xml.ISBLANKCHEQUE "No"
        		xml.ISVOID "No"
        		xml.ISONHOLD "No"
        		xml.ORDERLINESTATUS "No"
        		xml.VATISAGNSTCANCSALES "No"
        		xml.VATISPURCEXEMPTED "No"
        		xml.ISVATRESTAXINVOICE "No"
        		xml.VATISASSESABLECALCVCH "No"
        		xml.ISVATDUTYPAID "Yes"
        		xml.ISDELIVERYSAMEASCONSIGNEE "No"
        		xml.ISDISPATCHSAMEASCONSIGNOR "No"	
        		xml.ISDELETED "No"
        		xml.CHANGEVCHMODE "No"	
        		xml.ALTERID "406"
        		xml.MASTERID "306"	
        		xml.VOUCHERKEY "183970629156984"
        		xml.tag! ("EXCLUDEDTAXATIONS.LIST")
        		xml.tag! ("OLDAUDITENTRIES.LIST")
        		xml.tag! ("ACCOUNTAUDITENTRIES.LIST")
        		xml.tag! ("AUDITENTRIES.LIST")
        		xml.tag! ("DUTYHEADDETAILS.LIST")
        		xml.tag! ("SUPPLEMENTARYDUTYHEADDETAILS.LIST")
        		xml.tag! ("EWAYBILLDETAILS.LIST")
        		xml.tag! ("INVOICEDELNOTES.LIST")
        		xml.tag! ("INVOICEORDERLIST.LIST")
        		xml.tag! ("INVOICEINDENTLIST.LIST")
        		xml.tag! ("ATTENDANCEENTRIES.LIST")
        		xml.tag! ("ORIGINVOICEDETAILS.LIST")
        		xml.tag! ("INVOICEEXPORTLIST.LIST")

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

            total_amount = 0
            @settlement_data.each do |type,sale_amount|
              if type.to_s.include? 'sale'
                type = type.to_s.split('_sale')[0]
                sale_amount = sale_amount + @extra_amount if type == 'cash'
            		xml.tag! ("LEDGERENTRIES.LIST") do
            			xml.tag!("OLDAUDITENTRYIDS.LIST", "TYPE"=>"Number") do
            				xml.OLDAUDITENTRYIDS "-1"
            			end
            			# xml.LEDGERNAME "Cash"  #payment Mode Name
                  xml.LEDGERNAME "#{type.humanize.titleize}"  #payment Mode Name
            			xml.GSTCLASS
            			xml.ISDEEMEDPOSITIVE "Yes"
            			xml.LEDGERFROMITEM "No"
            			xml.REMOVEZEROENTRIES "No"
            			if type == 'cash'
            				xml.ISPARTYLEDGER "Yes"
            			else
            				xml.ISPARTYLEDGER "No"
            			end
            			xml.ISLASTDEEMEDPOSITIVE "Yes"
            			xml.ISCAPVATTAXALTERED "No"

                  #cash_sale = (@settlement_data[:total_settlement].to_f - @round_off[0].total_roundoff.to_f).round
                  #cash_sale = @settlement_data[:total_settlement]
                  #xml.kk @total_amount
            			# xml.AMOUNT "-#{@total_amount_with_tax}" #Total Amount as Negetive 
                  xml.AMOUNT "-#{sale_amount}" #Total Amount as Negetive
            			xml.tag! ("SERVICETAXDETAILS.LIST")
            			xml.tag! ("BANKALLOCATIONS.LIST")
            			xml.tag! ("BILLALLOCATIONS.LIST")
            			xml.tag! ("INTERESTCOLLECTION.LIST")
            			xml.tag! ("OLDAUDITENTRIES.LIST")
            			xml.tag! ("ACCOUNTAUDITENTRIES.LIST")
            			xml.tag! ("AUDITENTRIES.LIST")
            			xml.tag! ("INPUTCRALLOCS.LIST")
            			xml.tag! ("DUTYHEADDETAILS.LIST")
            			xml.tag! ("EXCISEDUTYHEADDETAILS.LIST")
            			xml.tag! ("RATEDETAILS.LIST")
            			xml.tag! ("SUMMARYALLOCS.LIST")
            			xml.tag! ("STPYMTDETAILS.LIST")
            			xml.tag! ("EXCISEPAYMENTALLOCATIONS.LIST")
            			xml.tag! ("TAXBILLALLOCATIONS.LIST")
            			xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
            			xml.tag! ("TDSEXPENSEALLOCATIONS.LIST")
            			xml.tag! ("VATSTATUTORYDETAILS.LIST")
            			xml.tag! ("COSTTRACKALLOCATIONS.LIST")
            			xml.tag! ("REFVOUCHERDETAILS.LIST")
            			xml.tag! ("INVOICEWISEDETAILS.LIST")
            			xml.tag! ("VATITCDETAILS.LIST")
            			xml.tag! ("ADVANCETAXDETAILS.LIST")
            		end
              end
            end

            xml.tag! ("LEDGERENTRIES.LIST") do
              xml.tag!("OLDAUDITENTRYIDS.LIST", "TYPE"=>"Number") do
                xml.OLDAUDITENTRYIDS "-1"
              end
              xml.tag!("BASICRATEOFINVOICETAX.LIST", "TYPE"=>"Number") do
                xml.BASICRATEOFINVOICETAX "2.50"
              end
              xml.ROUNDTYPE
              xml.LEDGERNAME "CGST @ 2.5%"
              xml.GSTCLASS
              xml.ISDEEMEDPOSITIVE "No"
              xml.LEDGERFROMITEM "No"
              xml.REMOVEZEROENTRIES "No"
              xml.ISPARTYLEDGER "No"
              xml.ISLASTDEEMEDPOSITIVE "No"
              xml.ISCAPVATTAXALTERED "No"
              xml.AMOUNT "#{@total_tax.round/2.round(2)}"
              xml.VATEXPAMOUNT "#{@total_tax.round/2.round(2)}"
              xml.tag! ("SERVICETAXDETAILS.LIST")
              xml.tag! ("BANKALLOCATIONS.LIST")
              xml.tag! ("BILLALLOCATIONS.LIST")
              xml.tag! ("INTERESTCOLLECTION.LIST")
              xml.tag! ("OLDAUDITENTRIES.LIST")
              xml.tag! ("ACCOUNTAUDITENTRIES.LIST")
              xml.tag! ("AUDITENTRIES.LIST")
              xml.tag! ("INPUTCRALLOCS.LIST")
              xml.tag! ("DUTYHEADDETAILS.LIST")
              xml.tag! ("EXCISEDUTYHEADDETAILS.LIST")
              xml.tag! ("RATEDETAILS.LIST")
              xml.tag! ("SUMMARYALLOCS.LIST")
              xml.tag! ("STPYMTDETAILS.LIST")
              xml.tag! ("EXCISEPAYMENTALLOCATIONS.LIST")
              xml.tag! ("TAXBILLALLOCATIONS.LIST")
              xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
              xml.tag! ("TDSEXPENSEALLOCATIONS.LIST")
              xml.tag! ("VATSTATUTORYDETAILS.LIST")
              xml.tag! ("COSTTRACKALLOCATIONS.LIST")
              xml.tag! ("REFVOUCHERDETAILS.LIST")
              xml.tag! ("INVOICEWISEDETAILS.LIST")
              xml.tag! ("VATITCDETAILS.LIST")
              xml.tag! ("ADVANCETAXDETAILS.LIST")
            end

            xml.tag! ("LEDGERENTRIES.LIST") do
              xml.tag!("OLDAUDITENTRYIDS.LIST", "TYPE"=>"Number") do
                xml.OLDAUDITENTRYIDS "-1"
              end
              xml.tag!("BASICRATEOFINVOICETAX.LIST", "TYPE"=>"Number") do
                xml.BASICRATEOFINVOICETAX "2.50"
              end
              xml.ROUNDTYPE
              xml.LEDGERNAME "SGST @ 2.5%"
              xml.GSTCLASS
              xml.ISDEEMEDPOSITIVE "No"
              xml.LEDGERFROMITEM "No"
              xml.REMOVEZEROENTRIES "No"
              xml.ISPARTYLEDGER "No"
              xml.ISLASTDEEMEDPOSITIVE "No"
              xml.ISCAPVATTAXALTERED "No"
              xml.AMOUNT "#{@total_tax.round/2.round(2)}"
              xml.VATEXPAMOUNT "#{@total_tax.round/2.round(2)}"
              xml.tag! ("SERVICETAXDETAILS.LIST")
              xml.tag! ("BANKALLOCATIONS.LIST")
              xml.tag! ("BILLALLOCATIONS.LIST")
              xml.tag! ("INTERESTCOLLECTION.LIST")
              xml.tag! ("OLDAUDITENTRIES.LIST")
              xml.tag! ("ACCOUNTAUDITENTRIES.LIST")
              xml.tag! ("AUDITENTRIES.LIST")
              xml.tag! ("INPUTCRALLOCS.LIST")
              xml.tag! ("DUTYHEADDETAILS.LIST")
              xml.tag! ("EXCISEDUTYHEADDETAILS.LIST")
              xml.tag! ("RATEDETAILS.LIST")
              xml.tag! ("SUMMARYALLOCS.LIST")
              xml.tag! ("STPYMTDETAILS.LIST")
              xml.tag! ("EXCISEPAYMENTALLOCATIONS.LIST")
              xml.tag! ("TAXBILLALLOCATIONS.LIST")
              xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
              xml.tag! ("TDSEXPENSEALLOCATIONS.LIST")
              xml.tag! ("VATSTATUTORYDETAILS.LIST")
              xml.tag! ("COSTTRACKALLOCATIONS.LIST")
              xml.tag! ("REFVOUCHERDETAILS.LIST")
              xml.tag! ("INVOICEWISEDETAILS.LIST")
              xml.tag! ("VATITCDETAILS.LIST")
              xml.tag! ("ADVANCETAXDETAILS.LIST")
            end

            order_id_for_bill = Bill.by_recorded_at(@from_datetime,@to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
            
            @menu_card.menu_products.each do |data| 
              # menu_product_name = data.product.name.humanize
              menu_product_name = data.product.name
              sweet_sale              = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.id).sum("unit_price_without_tax * quantity")
              # sweet_sale              = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.id).sum("subtotal")
              sweet_quentity          = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.id).sum("quantity")
              sweet_product_sale      = sweet_sale.to_f.round
              sweet_product_quentity  = sweet_quentity.to_f.round(2)

              # total_amount += sweet_product_sale
              if sweet_product_quentity!=0
                xml.tag! ("ALLINVENTORYENTRIES.LIST") do
                  xml.STOCKITEMNAME "#{menu_product_name}"
                  xml.ISDEEMEDPOSITIVE "No"
                  xml.ISLASTDEEMEDPOSITIVE "No"
                  xml.ISAUTONEGATE "No"
                  xml.ISCUSTOMSCLEARANCE "No"
                  xml.ISTRACKCOMPONENT "No"
                  xml.ISTRACKPRODUCTION "No"
                  xml.ISPRIMARYITEM "No"
                  xml.ISSCRAP "No"
                  rate = (sweet_product_sale.to_f / sweet_product_quentity.to_f).round(2)
                  if rate.nan?
                    rate = 0
                  end
                  xml.RATE "#{rate}" "/#{data.product.basic_unit}"
                  xml.AMOUNT sweet_product_sale.to_f
                  xml.ACTUALQTY "#{sweet_product_quentity}" " #{data.product.basic_unit}"
                  xml.BILLEDQTY "#{sweet_product_quentity}" " #{data.product.basic_unit}"
                  xml.tag! ("BATCHALLOCATIONS.LIST") do
                    godown_name=AppConfiguration.get_config('tally_godown_name')
                    if godown_name.nil? || godown_name.empty?
                      xml.GODOWNNAME "#{@unit.unit_name}"
                    else
                      xml.GODOWNNAME godown_name
                    end
                    xml.BATCHNAME "Primary Batch"
                    # xml.DESTINATIONGODOWNNAME "UNIT - 1"
                    # 
                    xml.INDENTNO
                    xml.ORDERNO
                    xml.TRACKINGNUMBER
                    xml.DYNAMICCSTISCLEARED "No"
                    xml.AMOUNT "#{sweet_product_sale.to_f}"
                    xml.ACTUALQTY "#{sweet_product_quentity}" " #{data.product.basic_unit}"
                    xml.BILLEDQTY "#{sweet_product_quentity}" " #{data.product.basic_unit}"
                    xml.tag! ("ADDITIONALDETAILS.LIST")
                    xml.tag! ("VOUCHERCOMPONENTLIST.LIST")
                  end
                  xml.tag! ("ACCOUNTINGALLOCATIONS.LIST") do
                    xml.tag!("OLDAUDITENTRYIDS.LIST", "TYPE"=>"Number") do
                      xml.OLDAUDITENTRYIDS "-1"
                    end
                    xml.LEDGERNAME "Sales"
                    xml.GSTCLASS
                    xml.ISDEEMEDPOSITIVE "No"
                    xml.LEDGERFROMITEM "No"
                    xml.REMOVEZEROENTRIES "No"
                    xml.ISPARTYLEDGER "No"
                    xml.ISLASTDEEMEDPOSITIVE "No"
                    xml.ISCAPVATTAXALTERED "No"
                    xml.AMOUNT "#{sweet_product_sale.to_f}"
                    xml.tag! ("SERVICETAXDETAILS.LIST")
                    xml.tag! ("BANKALLOCATIONS.LIST")
                    xml.tag! ("BILLALLOCATIONS.LIST")
                    xml.tag! ("INTERESTCOLLECTION.LIST")
                    xml.tag! ("OLDAUDITENTRIES.LIST")
                    xml.tag! ("ACCOUNTAUDITENTRIES.LIST")
                    xml.tag! ("AUDITENTRIES.LIST")
                    xml.tag! ("INPUTCRALLOCS.LIST")
                    xml.tag! ("DUTYHEADDETAILS.LIST")
                    xml.tag! ("EXCISEDUTYHEADDETAILS.LIST")
                    xml.tag! ("RATEDETAILS.LIST")
                    xml.tag! ("SUMMARYALLOCS.LIST")
                    xml.tag! ("STPYMTDETAILS.LIST")
                    xml.tag! ("EXCISEPAYMENTALLOCATIONS.LIST")
                    xml.tag! ("TAXBILLALLOCATIONS.LIST")
                    xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
                    xml.tag! ("TDSEXPENSEALLOCATIONS.LIST")
                    xml.tag! ("VATSTATUTORYDETAILS.LIST")
                    xml.tag! ("COSTTRACKALLOCATIONS.LIST")
                    xml.tag! ("REFVOUCHERDETAILS.LIST")
                    xml.tag! ("INVOICEWISEDETAILS.LIST")
                    xml.tag! ("VATITCDETAILS.LIST")
                    xml.tag! ("ADVANCETAXDETAILS.LIST")
                  end
                  xml.tag! ("DUTYHEADDETAILS.LIST")
                  xml.tag! ("SUPPLEMENTARYDUTYHEADDETAILS.LIST")
                  xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
                  xml.tag! ("REFVOUCHERDETAILS.LIST")
                  xml.tag! ("EXCISEALLOCATIONS.LIST")
                  xml.tag! ("EXPENSEALLOCATIONS.LIST")
                end
              end
            end

        		# xml.kk0 total_amount.round

        		# xml.tag! ("ALLINVENTORYENTRIES.LIST") do
        		# 	xml.STOCKITEMNAME "Snacks"
        		# 	xml.ISDEEMEDPOSITIVE "No"
        		# 	xml.ISLASTDEEMEDPOSITIVE "No"
        		# 	xml.ISAUTONEGATE "No"
        		# 	xml.ISCUSTOMSCLEARANCE "No"
        		# 	xml.ISTRACKCOMPONENT "No"
        		# 	xml.ISTRACKPRODUCTION "No"
        		# 	xml.ISPRIMARYITEM "No"
        		# 	xml.ISSCRAP "No"
        		# 	xml.RATE "#{(nonta_product_sale.to_f / nonta_product_quentity.to_f).round(2)}" "/Pc"
        		# 	xml.AMOUNT "#{nonta_product_sale.to_f}"
        		# 	xml.ACTUALQTY "#{nonta_product_quentity}" " Pc"
        		# 	xml.BILLEDQTY "#{nonta_product_quentity}" " Pc"
        		# 	xml.tag! ("BATCHALLOCATIONS.LIST") do
        		# 		xml.MFDON Date.today.strftime('%Y%m%d')
        		# 		xml.GODOWNNAME "#{@unit.unit_name}"
        		# 		xml.BATCHNAME "Primary Batch"
        		# 		# xml.DESTINATIONGODOWNNAME "UNIT - 1"
        		# 		xml.INDENTNO
        		# 		xml.ORDERNO
        		# 		xml.TRACKINGNUMBER
        		# 		xml.DYNAMICCSTISCLEARED "No"
        		# 		xml.AMOUNT "#{nonta_product_sale.to_f}"
        		# 		xml.ACTUALQTY "#{nonta_product_quentity}" " Pc"
        		# 		xml.BILLEDQTY "#{nonta_product_quentity}" " Pc"
        		# 		xml.tag! ("ADDITIONALDETAILS.LIST")
        		# 		xml.tag! ("VOUCHERCOMPONENTLIST.LIST")
        		# 	end
        		# 	xml.tag! ("ACCOUNTINGALLOCATIONS.LIST") do
        		# 		xml.tag!("OLDAUDITENTRYIDS.LIST", "TYPE"=>"Number") do
        		# 			xml.OLDAUDITENTRYIDS "-1"
        		# 		end
        		# 		xml.LEDGERNAME "Sales"
        		# 		xml.GSTCLASS
        		# 		xml.ISDEEMEDPOSITIVE "No"
        		# 		xml.LEDGERFROMITEM "No"
        		# 		xml.REMOVEZEROENTRIES "No"
        		# 		xml.ISPARTYLEDGER "No"
        		# 		xml.ISLASTDEEMEDPOSITIVE "No"
        		# 		xml.ISCAPVATTAXALTERED "No"
        		# 		xml.AMOUNT "#{nonta_product_sale.to_f}"
        		# 		xml.tag! ("SERVICETAXDETAILS.LIST")
        		# 		xml.tag! ("BANKALLOCATIONS.LIST")
        		# 		xml.tag! ("BILLALLOCATIONS.LIST")
        		# 		xml.tag! ("INTERESTCOLLECTION.LIST")
        		# 		xml.tag! ("OLDAUDITENTRIES.LIST")
        		# 		xml.tag! ("ACCOUNTAUDITENTRIES.LIST")
        		# 		xml.tag! ("AUDITENTRIES.LIST")
        		# 		xml.tag! ("INPUTCRALLOCS.LIST")
        		# 		xml.tag! ("DUTYHEADDETAILS.LIST")
        		# 		xml.tag! ("EXCISEDUTYHEADDETAILS.LIST")
        		# 		xml.tag! ("RATEDETAILS.LIST")
        		# 		xml.tag! ("SUMMARYALLOCS.LIST")
        		# 		xml.tag! ("STPYMTDETAILS.LIST")
        		# 		xml.tag! ("EXCISEPAYMENTALLOCATIONS.LIST")
        		# 		xml.tag! ("TAXBILLALLOCATIONS.LIST")
        		# 		xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
        		# 		xml.tag! ("TDSEXPENSEALLOCATIONS.LIST")
        		# 		xml.tag! ("VATSTATUTORYDETAILS.LIST")
        		# 		xml.tag! ("COSTTRACKALLOCATIONS.LIST")
        		# 		xml.tag! ("REFVOUCHERDETAILS.LIST")
        		# 		xml.tag! ("INVOICEWISEDETAILS.LIST")
        		# 		xml.tag! ("VATITCDETAILS.LIST")
        		# 		xml.tag! ("ADVANCETAXDETAILS.LIST")
        		# 	end
        		# 	xml.tag! ("DUTYHEADDETAILS.LIST")
      				# xml.tag! ("SUPPLEMENTARYDUTYHEADDETAILS.LIST")
      				# xml.tag! ("TAXOBJECTALLOCATIONS.LIST")
      				# xml.tag! ("REFVOUCHERDETAILS.LIST")
      				# xml.tag! ("EXCISEALLOCATIONS.LIST")
      				# xml.tag! ("EXPENSEALLOCATIONS.LIST")
        		# end
        		
            xml.tag! ("PAYROLLMODEOFPAYMENT.LIST")
    				xml.tag! ("ATTDRECORDS.LIST")
    				xml.tag! ("TEMPGSTRATEDETAILS.LIST")
    				xml.tag! ("GSTEWAYCONSIGNORADDRESS.LIST")
    				xml.tag! ("GSTEWAYCONSIGNEEADDRESS.LIST")
        	end
        end
        xml.TALLYMESSAGE("xmlns:UDF"=>"TallyUDF") do
        	xml.COMPANY do
        		xml.tag!("REMOTECMPINFO.LIST","MERGE"=>"Yes") do
        			xml.NAME "78af428e-22ef-4175-ac69-5e9882a6dccc"
        			xml.REMOTECMPNAME AppConfiguration.get_config('tally_company_name')
        			xml.REMOTECMPSTATE AppConfiguration.get_config('tally_state_name')
        		end
        	end
        end
        xml.TALLYMESSAGE("xmlns:UDF"=>"TallyUDF") do
        	xml.COMPANY do
        		xml.tag!("REMOTECMPINFO.LIST","MERGE"=>"Yes") do
        			xml.NAME "78af428e-22ef-4175-ac69-5e9882a6dccc"
        			xml.REMOTECMPNAME AppConfiguration.get_config('tally_company_name')
        			xml.REMOTECMPSTATE AppConfiguration.get_config('tally_state_name')
        		end
        	end
        end

      end
    end
  end
end