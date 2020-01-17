class StockPurchasePaymentsController < ApplicationController
  def create
  	vendor = Vendor.find(params[:vendor_id])
  	@stock_purchase_payment = StockPurchasePayment.new(:payment_amount =>params[:payment_amount],:payment_mode =>params[:payment_mode],:stock_purchase_id =>params[:stock_purchase_id], :vendor_id =>params[:vendor_id], :details => params[:details], :payment_date => params[:payment_date])
    respond_to do |format|
      if@stock_purchase_payment.save
      	@stock_purchase = StockPurchase.find(params[:stock_purchase_id])
      	paid_amount = 0
      	paid_amount = @stock_purchase.paid_amount if @stock_purchase.paid_amount.present?
        paid_amount = paid_amount + params[:payment_amount].to_f
        @stock_purchase.update_attribute(:paid_amount, paid_amount)
        StockPurchase.update_payment_status(@stock_purchase)
        format.html { redirect_to payment_details_vendor_path(vendor), notice: 'Payment was sucessfully intiated.' }
      end
    end
  end
end
