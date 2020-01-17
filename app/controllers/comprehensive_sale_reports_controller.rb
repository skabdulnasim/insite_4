class ComprehensiveSaleReportsController < ApplicationController
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  include ComprehensiveSaleReportsHelper
  include ActionView::Helpers::NumberHelper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:bill_by_bill_report]

  def index
    _unit_ids = BillByBillSale.select("DISTINCT(unit_id)")
    @units = Unit.get_unit_name(_unit_ids).order("unit_name asc")
    respond_to do |format|
      format.html
      format.json { render json: @units }
    end
  end

  def bill_by_bill_report
    @unit_arr = params['unit_ids']
    @unit_arr = @unit_arr.reject { |c| c.empty? } if @unit_arr.present?
    
    @units = Unit.set_id_in(@unit_arr)
    # @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    # @unit = Unit.find(@unit_id)
    # @sections = @unit.sections
    @sections = Section.unit_ids_in(@unit_arr)
    @bill_by_bill_sales = BillByBillSale.set_unit_ids_in(@unit_arr).by_recorded_at(@from_datetime,@to_datetime).order("recorded_at asc")
    @deliverable = BillByBillSale.select("DISTINCT(deliverable_type)")
    @bill_statuses = BillByBillSale.select("DISTINCT(status)")

    if params[:deliverable_type].present?
      @bill_by_bill_sales = @bill_by_bill_sales.set_deliverable_type(params[:deliverable_type])
      if params[:deliverable_type] == "Section"
        @bill_by_bill_sales = @bill_by_bill_sales.section_bill(params[:section_id]) if params[:section_id].present?
      else
        @bill_by_bill_sales = @bill_by_bill_sales.by_section(params[:section_id]) if params[:section_id].present?
      end
    else
      @bill_by_bill_sales = @bill_by_bill_sales.by_section(params[:section_id]) if params[:section_id].present?
    end
    # @bill_by_bill_sales = @bill_by_bill_sales.by_paymentmode_type(params[:paymentmode]) if params[:paymentmode].present?
    @bill_by_bill_sales = @bill_by_bill_sales.only_discount_bills if params[:discountmode].present?
    # @bill_by_bill_sales = @bill_by_bill_sales.joins(:orders).merge(Order.check_order_source(params[:order_sources])) if params[:order_sources].present?
    @bill_by_bill_sales = @bill_by_bill_sales.valid_bill if params[:bill_validity].present?
    @bill_by_bill_sales = @bill_by_bill_sales.check_bill_status(params[:bill_statuses]) if params[:bill_statuses].present?

    smart_listing_create :bill_by_bill_sales, @bill_by_bill_sales, partial: "comprehensive_sale_reports/bill_by_bill_sales_smartlist",default_sort: {recorded_at: "asc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data bill_by_bill_report_to_csv(@bill_by_bill_sales), filename: "comprehensive-sale-report-#{params[:from_date]}-to-#{params[:to_date]}.csv" }
    end

  end

  private

  def set_module_details
    @module_id = "reports"
    @module_title = "Comprehensive Sales Report"
  end

  def bill_by_bill_report_to_csv(sales)
    report_precision = AppConfiguration.get_config_value_of_report('report_precision').to_i

    _report_attributes = Bill.report_attributes
    total_attributes_length = _report_attributes['tax'].count + _report_attributes['payment'].count + _report_attributes['third_party'].count

    csv_header = Array.new
    csv_header_1 = ["Bill ID","Bill Serial","Recorded Date","Created Date","Outlet Name","Order Source","Third Party Order Id","Delivery Type","Deliverables At","Section","Biller","Remarks"]    

    csv_header_1_1 = ["Customer Name","Customer Mobile","Shipping Address","Landmark","Server Name","Calling Time","Delivery Time","GSR","Customer Tags","Product Count"]

    csv_header_6 = ["Order Item Name","Item Category","Order Item Quantity","Product Cost","Order Item Tax","Order Item Discount Per Unit","Order Item Unit Price"]

    csv_header_3 = ["Bill Amount (without Tax)","Discount","Total Tax"]

    csv_header_2 = Array.new
    _report_attributes['tax'].each do |attribute|
      csv_header_2.push attribute.humanize
    end

    csv_header_5 = ["Delivery Charges","Roundoff","Total","Order Status","Bill Status"]

    csv_header_4 = Array.new
    _report_attributes['third_party'].each do |attribute|
      csv_header_4.push attribute.humanize
    end
    _report_attributes['payment'].each do |attribute|
      csv_header_4.push attribute.humanize
    end

    csv_header_7 = ["Pax","Order Id","Order Details Id"]
    
    csv_header = csv_header + csv_header_1 + csv_header_1_1  + csv_header_6 + csv_header_3 + csv_header_2 + csv_header_5 + csv_header_4 + csv_header_7
    CSV.generate do |csv|
      csv<<csv_header
      sales.each do |object|
        row_array = Array.new
        order_details = JSON.parse(object.order_details)
        
        bill_id = object.bill_id
        serial_no = "#{object.prefix}""#{object.serial_no}""#{object.suffix}"
        recorded_at = object.recorded_at.strftime("%d-%m-%Y, %I:%M %p")
        created_at = object.created_at.strftime("%d-%m-%Y, %I:%M %p")
        unit_name = JSON.parse(object.unit)[0]['unit_name']
        source = JSON.parse(object.orders)[0]['source']
        third_party_order_id = JSON.parse(object.orders)[0]['third_party_order_id']
        delivery_type = JSON.parse(object.orders)[0]['delivery_type']
        bill_deliverable = JSON.parse(object.deliverable)
        # deliverable_type = bill_deliverable[0].length > 0 ? show_delivery_name_from_json(bill_deliverable[0]) : object.deliverable_type
        deliverable_type = bill_deliverable[0].length > 0 ? bill_deliverable[0].keys.first : object.deliverable_type
        section_name = JSON.parse(object.section)[0] != nil ? JSON.parse(object.section)[0]['name'] : "-"

        _biller_name = JSON.parse(object.biller)[0].keys.second == 'profile' ? "#{JSON.parse(object.biller)[0]['profile']['firstname']}" : "#{JSON.parse(object.biller)[0]['email']}"
        remarks = object.remarks
        
        _customer_name = JSON.parse(object.customer)[0] != nil ? "#{JSON.parse(object.customer)[0]['profile']['firstname']} #{JSON.parse(object.customer)[0]['profile']['lastname']}" : "-"
        customer_mobile_no = JSON.parse(object.customer)[0] != nil ? JSON.parse(object.customer)[0]['customer']['mobile_no'] : '-'
        delivery_address = bill_deliverable[0].length > 0 ? bill_deliverable[0].keys.first == 'address' ? bill_deliverable[0]['address']['delivery_address'] : '-' : '-'
        landmark = bill_deliverable[0].length > 0 ? bill_deliverable[0].keys.first == 'address' ? bill_deliverable[0]['address']['landmark'] : '-' : '-'

        server_name = '-'
        calling_time = '-'
        delivary_date = Date.parse(JSON.parse(object.orders)[0]['delivary_date']).strftime("%Y-%m-%d %I:%M %p")
        gsr = '-'
        customer_tags = '-'

        product_count = order_details.count
        bill_amount = number_to_currency(object.bill_amount, unit: '', precision: report_precision)

        csv_data1 = [bill_id,serial_no,recorded_at,created_at,unit_name,source,third_party_order_id,delivery_type,deliverable_type,section_name,_biller_name,remarks]
        csv_data1_1 = [_customer_name,customer_mobile_no,delivery_address,landmark,server_name,calling_time,delivary_date,gsr,customer_tags,product_count]


        bill_tax_amount = number_to_currency(object.tax_amount, unit: '', precision: report_precision)
        discount = number_to_currency(object.discount, unit: '', precision: report_precision)
        grand_total = number_to_currency(object.grand_total, unit: '', precision: report_precision)

        # csv_data3 = [bill_tax_amount,discount,grand_total]

        row_array_data1 = csv_data1 + csv_data1_1

        od_count = 0
        order_details.each do |o_d|
          od_count = od_count + 1
          if od_count == 1
            product_name = o_d['product_name']
            p_category = o_d['p_category']
            quantity = o_d['quantity']
            unit_price_with_tax = o_d['unit_price_with_tax']
            item_price = o_d['material_cost']
            _discount = o_d['discount']
            tax_amount = o_d['tax_amount']
            order_id = o_d['order_id']
            od_id = o_d['id']
            order_details_row = [product_name, p_category, quantity, item_price, tax_amount, _discount, unit_price_with_tax]
            row_array_data2 = row_array_data1 + order_details_row

            # csv<<row_array_data

            csv_data2 = Array.new
            csv_data2.push bill_amount
            csv_data2.push discount
            csv_data2.push bill_tax_amount

            tax_class_amount = ''
            _bill_taxes = JSON.parse(object.bill_taxes)
            _report_attributes['tax'].each do |attribute|
              printed_tax_count = 0
              if _bill_taxes != nil
                _bill_taxes.each do |b_tax|
                  if b_tax['tax_class_name'] != nil
                    if b_tax['tax_class_name'].downcase == attribute.downcase
                      tax_class_amount = b_tax['tax_amount']
                      printed_tax_count = 1
                    end
                  end
                end
                if printed_tax_count == 0
                  tax_class_amount = '-'
                end
              else
                tax_class_amount = '-'
              end
              csv_data2.push tax_class_amount
            end

            row_array_data3 = row_array_data2 + csv_data2

            pax = object.pax
            roundoff = object.roundoff
            order_status = OrderStatus.find(JSON.parse(object.orders)[0]['order_status_id']).name
            bill_status = object.status.humanize
            delivery_charge = JSON.parse(object.orders)[0]['delivery_charges']

            csv_data5 = [delivery_charge,roundoff,grand_total,order_status,bill_status]

            row_array_data5 = row_array_data3 + csv_data5

            csv_data4 = Array.new

            if object.status == "paid"
              _payments = JSON.parse(object.payments)

              third_party_amount = ''
              _report_attributes['third_party'].each do |attribute|
                printed_third_party_payment_count = 0
                if _payments != nil
                  _payments.each do |pt|
                    if pt['p_mode_name'] != nil
                      if pt['p_mode_name'].downcase == attribute.downcase
                        third_party_amount = pt['amount']
                        printed_third_party_payment_count = 1
                      end
                    end
                  end
                  if printed_third_party_payment_count == 0
                    third_party_amount = '-'
                  end
                else
                  third_party_amount = '-'
                end
                csv_data4.push third_party_amount
              end

              p_mode_amount = '-'
              _report_attributes['payment'].each do |attribute|
                printed_payment_count = 0
                if _payments != nil
                  _payments.each do |pt|
                    if pt['p_mode_name'] != nil
                      if pt['p_mode_name'].downcase == attribute.downcase
                        p_mode_amount = pt['amount']
                        printed_payment_count = 1
                      end
                    end
                  end
                  if printed_payment_count == 0
                    p_mode_amount = '-'
                  end
                else
                  p_mode_amount = '-'
                end
                csv_data4.push p_mode_amount
              end

            else
              _report_attributes['payment'].each do |attribute|
                csv_data4.push '-'
              end
              _report_attributes['third_party'].each do |attribute|
                csv_data4.push '-'
              end
            end

            csv_data4.push pax

            csv_data5 = [order_id, od_id]

            row_array_data = row_array_data5 + csv_data4 + csv_data5

            csv<<row_array_data

          else
            # %td{:colspan => 28+total_attributes_length}
            od_array = Array.new
            product_name = o_d['product_name']
            p_category = o_d['p_category']
            quantity = "#{o_d['quantity']} #{o_d['p_basic_unit']}"
            unit_price_with_tax = o_d['unit_price_with_tax']
            item_price = o_d['material_cost']
            _discount = o_d['discount']
            tax_amount = o_d['tax_amount']
            order_id = o_d['order_id']
            od_id = o_d['id']

            od_array1 = csv_data1
            
            (1..10).each do |_index|
              od_array.push ""
            end

            od_array2 = od_array1 + od_array

            order_details_row_2 = [product_name, p_category, quantity, item_price, tax_amount, _discount, unit_price_with_tax]
            od_array3 = od_array2 + order_details_row_2

            od_array4 = Array.new
            (1..9+total_attributes_length).each do |_index|
              od_array4.push ""
            end

            od_array6 = [order_id, od_id]
            od_array5 = od_array3 + od_array4 + od_array6           

            # row_array_data = row_array_data + od_array
            # puts row_array_data
            # csv<<row_array_data
            csv<<od_array5
          end
        end

        if object.order_detail_combinations.present?
          order_detail_combinations = JSON.parse(object.order_detail_combinations)
          order_detail_combinations.each do |odc|
            addons_array = Array.new
            (1..22).each do |_index|
              addons_array.push ""
            end
            product_name = odc['product_name']
            p_category = odc['p_category']
            quantity = "#{odc['combination_qty']} #{odc['p_basic_unit']}"
            product_price = odc['product_price']
            item_price = "-"
            tax_amount = "-"
            _discount = "-"
            order_id = odc['order_id']
            od_id = odc['order_detail_id']
            addons_row = [product_name, p_category, quantity, item_price, tax_amount, _discount, unit_price_with_tax]
            addons_array1 = addons_array + addons_row

            addons_array2 = Array.new
            (1..9+total_attributes_length).each do |_index|
              addons_array2.push ""
            end
            addons_array3 = [order_id, od_id]
            addons_array4 = addons_array1 + addons_array2 + addons_array3

            addons_array_data = addons_array4
            csv<<addons_array_data
          end
        end
      end
    end
  end
end