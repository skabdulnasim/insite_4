module Api
  module V2
    class PackagesController < ApplicationController
      load_and_authorize_resource
      def required_product_fields
        @categories = build_product_categories
        @basic_units = ProductBasicUnit.all
        @menu_cards = @current_user.unit.menu_cards

        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def add_package_component
        @package_component = PackageComponent.find_by_name(params[:name])
        if @package_component.present?
          @package_component = @package_component
        else  
          @package_component = PackageComponent.new
          @package_component.name = params[:name]
          @package_component.category_id = params[:category_id]
          @package_component.basic_unit_id = params[:basic_unit_id]

          unless @package_component.save
            @validation_errors = error_messages_for(@package_component)
          end
        end
      end

      def package_component_details
        ActiveRecord::Base.transaction do
          @package_component = PackageComponent.find(params[:package_component_id])
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def add_product
        @product = Product.find_by_name(params[:name])
        if @product.present?
          @product = @product
        else  
          @product = Product.new
          @product.product_type = "simple"
          @product.business_type = "by_catalog"
          @product.name = params[:name]
          @product.category_id = params[:category_id]
          @product.basic_unit_id = params[:basic_unit_id]
          @product.product_attribute_set_id = 1
          @product.package_component_id = params[:package_component_id]

          unless @product.save
            @validation_errors = error_messages_for(@product)
          end
        end
        if params[:menu_card_id].present? and params[:menu_category_id].present?
          mp = MenuProduct.set_product(@product.id).by_menu_card(params[:menu_card_id])
          unless mp.present?
            @menu_product = MenuProduct.new
            @menu_product.product_id = @product.id
            @menu_product.menu_card_id = params[:menu_card_id]
            @menu_product.menu_category_id = params[:menu_category_id]
            @menu_product.mode = 1
            @menu_product.procured_price = 0
            @menu_product.sell_price_without_tax = 0
            @menu_product.tax_group_id = MenuCard.find(params[:menu_card_id]).section.tax_groups.first.id
            
            unless @menu_product.save
              @validation_errors = error_messages_for(@menu_product)
            end
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def package_creation
        @package = Package.new
        @package.name = params[:name]
        @package.customer_id = params[:customer_id]
        unless @package.save
          @validation_errors = error_messages_for(@package)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def edit_package_name
        @package = Package.find(params[:id])
        if @package.present?
          unless @package.update_attributes(:name=>params[:name], :customer_id=>params[:customer_id])
            @validation_errors = error_messages_for(@package_unit)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def create_package_unit
        @package_unit = PackageUnit.new
        @package_unit.package_id = params[:package_id]
        @package_unit.parent = params[:parent_unit]
        @package_unit.unit_name = params[:package_unit_name]
        unless @package_unit.save
          @validation_errors = error_messages_for(@package_unit)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def edit_package_unit
        # package_unit_id = params[:id]
        @package_unit = PackageUnit.find(params[:package_unit_id])
        if @package_unit.present?
          unless @package_unit.update_attributes(:unit_name=>params[:package_unit_name])
            @validation_errors = error_messages_for(@package_unit)
          end
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def add_package_unit_product
        @package_unit_product = PackageUnitProduct.new
        @package_unit_product.package_unit_id = params[:package_unit_id]
        @package_unit_product.product_id = params[:product_id]
        @package_unit_product.quantity = params[:quantity]
        @package_unit_product.production_status = params[:production_status]
        
        unless @package_unit_product.save
          @validation_errors = error_messages_for(@package)
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def add_product_composition
        raw_product = Product.find_by_name(params[:raw_product_name])
        if raw_product.present?
          product_unit = raw_product.measurement_unit.product_units.where(:multiplier=>1).first
          @product_composition = ProductComposition.new
          @product_composition.product_id = params[:product_id]
          @product_composition.raw_product_id = raw_product.id
          @product_composition.raw_product_quantity = params[:raw_product_qty]
          @product_composition.raw_product_unit = product_unit.id
          @product_composition.basic_unit = raw_product.basic_unit

          unless @product_composition.save
            @validation_errors = error_messages_for(@product_composition)
          end
          @product_found = 'yes'
        else
          @product_found = 'no'
        end
        
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def package_details
        ActiveRecord::Base.transaction do
          @package = Package.find(params[:package_id])
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def remove_package_unit
        ActiveRecord::Base.transaction do
          @package_unit = PackageUnit.find(params[:package_unit_id])
          @package = @package_unit.package
          @package_unit.destroy if @package_unit.present?
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def remove_package_unit_product
        ActiveRecord::Base.transaction do
          @package_unit_product = PackageUnitProduct.find(params[:package_unit_product_id])
          @package = @package_unit_product.package
          @package_unit_product.destroy if @package_unit_product.present?
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end
    end
  end
end