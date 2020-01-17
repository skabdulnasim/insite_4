module Api
  module V2
    class QuotationsController < ApplicationController
      def index
        @quotations = Quotation.order('id desc')
        @quotations = @quotations.by_customer(params[:customer_id]) if params[:customer_id].present?
        @count = @quotations.size
        @quotations = @quotations.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
      def create
        begin 
          ActiveRecord::Base.transaction do
            #@quotation = Quotation.find_by_serial_no(params[:quotation][:serial_no]) if params[:quotation][:serial_no].present?
            @quotation = Quotation.new(params[:quotation]) unless @quotation.present?
            # _order = @quotation.bill_orders.first.order
            # @quotation = _order.bill if _order.billed? # Return bill if order already billed
            
            unless @quotation.new_record? and @quotation.save
              
              @validation_errors = error_messages_for(@quotation)
            end
          end
        rescue Exception => @error
          @order = Quotation.by_orders(params[:quotation][:order_ids]).first
        end
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def show
        @quotation = Quotation.find(params[:id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end