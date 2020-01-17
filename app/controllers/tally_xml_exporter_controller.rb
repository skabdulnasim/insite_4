class TallyXmlExporterController < ApplicationController
  layout "material"
  
  before_filter :set_module_details
  #before_filter :set_timerange
  # before_filter :get_current_user
  before_filter :set_timerange

  def index
  end
  
  def sales_xml
    
    @settlement_data = Bill.get_unit_settlement_data(current_user.unit_id,@from_datetime,@to_datetime)
    @outlet = current_user.unit
    respond_to do |format|
      format.html {send_data render_to_string(:sales_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
      format.xml  {send_data render_to_string(:sales_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
    end
    
    #CASH PAYMENT FOR A DATE
    #CARD PAYMENT FOR A DATE
    # SEVICE TAX FOR A DATE
    #SERVICE CHARGE FOR A DATE
    #FIRST LEVEL CATEGORY WISE TOTAL SALE
    #TOTAL DISCOUNT
    #TOTAL ROUND OFF IF AVAILABLE
  end

  def purchase_xml
    @outlet = current_user.unit
    @stores = current_user.unit.stores
    respond_to do |format|
      format.html {send_data render_to_string(:purchase_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
      format.xml {send_data render_to_string(:purchase_xml), filename: "P-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
    end
  end
  
  def from_date_to_date_xml
    @quentity = 0
    @settlement_data = Bill.get_unit_settlement_data(current_user.unit_id,@from_datetime,@to_datetime)
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @menu_card = @unit.menu_cards.last
    respond_to do |format|
      format.html {send_data render_to_string(:from_date_to_date_xml), filename: "#{@unit.unit_name}-Sale-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
      format.xml  {send_data render_to_string(:from_date_to_date_xml), filename: "#{@unit.unit_name}-Sale-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
    end
  end

  def voucher_xml
    @quentity = 0
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @unit = Unit.find(@unit_id)
    @menu_card = @unit.menu_cards.active.first
    @total_amount = 0
    sweet_product_sale = 0
    @total_tax = 0
    tax = 0
    #@menu_card = MenuCard.find(23)
    #@round_off = Bill.select("sum(roundoff) as total_roundoff").unit_bills(@unit_id).by_recorded_at(@from_datetime,@to_datetime).valid_bill
    @settlement_data = Bill.get_unit_settlement_data(@unit_id,@from_datetime,@to_datetime)
    order_id_for_bill = Bill.by_recorded_at(@from_datetime,@to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
    @menu_card.menu_products.each do |data| 
      sweet_sale              = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.id).sum("unit_price_without_tax * quantity")
      # sweet_sale              = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.id).sum("subtotal")
      sweet_product_sale      = sweet_sale.to_f.round
      tax                     = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>data.id).sum("tax_amount * quantity").to_f
      @total_amount += sweet_product_sale
      @total_tax += tax
    end
    @total_amount_with_tax = @total_amount.round + @total_tax.round
    # @total_amount_with_tax = @total_amount.round
    @extra_amount = @total_amount_with_tax - @settlement_data[:total_settlement]
    respond_to do |format|
      format.html {send_data render_to_string(:voucher_xml), filename: "#{@unit.unit_name}-voucher-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
      format.xml  {send_data render_to_string(:voucher_xml), filename: "#{@unit.unit_name}-voucher-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
    end
  end

  def hii_sales_xml
    @settlement_data = Bill.get_unit_settlement_data(current_user.unit_id,@from_datetime,@to_datetime)
    @outlet = current_user.unit
    respond_to do |format|
      format.html {send_data render_to_string(:hii_sales_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%Y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
      format.xml  {send_data render_to_string(:hii_sales_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%Y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
    end
  end

  def hii_journal_xml
    @settlement_data = Bill.get_unit_settlement_data(current_user.unit_id,@from_datetime,@to_datetime)
    @outlet = current_user.unit
    respond_to do |format|
      format.html {send_data render_to_string(:hii_sales_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
      format.xml  {send_data render_to_string(:hii_sales_xml), filename: "S-#{Date.parse(params[:from_date]).strftime('%y%m%d')}.xml", type: 'application/xml', disposition: 'attachment' }
    end
  end

  private

  def set_module_details
    @module_id = "third_party"
    @module_title = "Tally Integration"
  end  

end
