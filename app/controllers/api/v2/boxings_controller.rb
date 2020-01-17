module Api
  module V2
    class BoxingsController < ApplicationController

    	def create
    		@boxing = Boxing.new(params[:boxing])
    		unless @boxing.save
          @validation_errors = error_messages_for(@boxing)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

    	def update
    		@boxing = Boxing.find(params[:id])
    		if @boxing.present?
    			unless @boxing.update_attributes(params[:boxing])
    				@validation_errors = error_messages_for(@boxing)
        	end
    		end
    		rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

    	def search_by_barcode
    		@stock = Stock.available_sku_stock(params[:store_id],params[:sku]).first
        @product_stock = Stock.available_sku_stock(params[:store_id],params[:sku]).sum(:available_stock)
        puts @product_stock
    		if @stock.present?
          if params[:package_id].present?
            @qty_in_pckg = PackageUnitProduct.by_package(params[:package_id]).by_product(@stock.product_id).sum(:quantity)
            puts @qty_in_pckg
            if @product_stock >= @qty_in_pckg
              @stock_checked = 'yes'
            else
              @stock_checked = 'no'
            end
          end
          @product = @stock.product
     			@product_found = 'yes'
    		else
    			@product_found = 'no'
    		end
    		rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

    	def create_box
    		@box = Box.new(params[:box])
    		unless @box.save
          @validation_errors = error_messages_for(@box)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

    	def create_box_item
        @package = Package.find(params[:package_id])
        @package_unit_ids = []
        @package.package_units.map { |e| @package_unit_ids.push e.id }
        puts params[:box_item][:product_id]
        @package_unit_product = PackageUnitProduct.set_package_unit_in(@package_unit_ids).by_product(params[:box_item][:product_id])
    		@product_found_in_package = @package_unit_product.present? ? 'yes' : 'no'
        if @product_found_in_package == 'yes'
          @box_item = BoxItem.new(params[:box_item])
      		unless @box_item.save
            @validation_errors = error_messages_for(@box_item)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

      def show
        @boxing = Boxing.find(params[:id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def remove_box_item
        @box_item = BoxItem.find(params[:box_item_id])
        if @box_item.present?
          if @box_item.destroy
            @item_removed = 'yes'
          else
            @item_removed = 'no'
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end