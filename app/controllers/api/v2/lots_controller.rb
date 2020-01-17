module Api
  module V2
    class LotsController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/lots', "List of all lots."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      # param :menu_card_id, String, :required => true, :desc => "Active retail menu_card_id"
      param :unit_id, String, :required => true, :desc => "Id of unit from which you want all lot"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"      
      ### => 'index' API Defination
      def index
        _per  = params[:count] || 20
        # @lots = Lot.by_menu_card(params[:menu_card_id]).active_mode.active.not_expiry
        @unit = Unit.find(params[:unit_id])
        @unit_store_ids = @unit.stores.pluck(:id)
        @lots  = Lot.active_mode.active.not_expiry.set_store_id_in(@unit_store_ids) 
        @count = @lots.count
        @lots = @lots.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log  = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/lots/:id', "Lots Details."
      param :email, String, :required => false, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      ### => 'show' API Defination
      def show
        @lot = Lot.find(params[:id])
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'download lots' action
      api :GET, '/api/v2/lots/download_lots', "Lots download."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      # param :menu_card_id, String, :required => false, :desc => "Id of menucard from which menu you want stock"
      param :unit_id, String, :required => true, :desc => "Id of outlet from which you want lot"
      param :count, String, :required => false, :desc => "How many row required in csv file"
      def download_lots
        @file_array = Array.new()
        _per = params[:count] || 1000
        directory_name = Rails.root.join('public', 'lots')
        Dir.mkdir(directory_name) unless File.exists?(directory_name)
        #ActiveRecord::Base.connection.execute("COPY (select lots.*,menu_products.tax_group_id,product_basic_units.short_name as basic_unit from lots INNER JOIN menu_products on lots.menu_product_id = menu_products.id INNER JOIN products on menu_products.product_id = products.id INNER JOIN product_basic_units on products.basic_unit_id = product_basic_units.id where lots.stock_qty > 0) TO '#{Rails.root}/public/lots/#{request.subdomain}.csv' DELIMITER ',' CSV HEADER")
        #ActiveRecord::Base.connection.execute("COPY lots TO '#{Rails.root}/public/lots/#{request.subdomain}.csv' DELIMITER ',' CSV HEADER")
        @unit = Unit.find(params[:unit_id])
        @unit_store_ids = @unit.stores.pluck(:id)
        @lots  = Lot.active_mode.active.not_expiry.set_store_id_in(@unit_store_ids)
        # @lots = Lot.active_mode.active.not_expiry.by_menu_card(params[:menu_card_id]) if params[:menu_card_id].present?
        @lots = @lots.count
        _count = (@lots.to_f/_per.to_f).ceil
        if _count > 1
          for i in 1.._count
            File.open("#{Rails.root}/public/lots/#{request.subdomain}_#{i}.csv", 'wb') do |f|
              # if params[:menu_card_id].present?
              #   Lot.active_mode.active.not_expiry.by_menu_card(params[:menu_card_id]).page(i).per(_per).pg_copy_to do |line|
              #     f.write line
              #   end
              # else
              #   Lot.active_mode.active.not_expiry.page(i).per(_per).pg_copy_to do |line|
              #     f.write line
              #   end
              # end
              Lot.active_mode.active.not_expiry.set_store_id_in(@unit_store_ids).page(i).per(_per).copy_to do |line|
                f.write line
              end    
            end
            @file_array <<  "#{request.subdomain}_#{i}.csv"
          end  
        else
          File.open("#{Rails.root}/public/lots/#{request.subdomain}_1.csv", 'wb') do |f|
            # if params[:menu_card_id].present?
            #   Lot.active_mode.active.not_expiry.by_menu_card(params[:menu_card_id]).pg_copy_to do |line|
            #     f.write line
            #   end
            # else
            #   Lot.active_mode.active.not_expiry.pg_copy_to do |line|
            #     f.write line
            #   end
            # end
            Lot.active_mode.active.not_expiry.set_store_id_in(@unit_store_ids).copy_to do |line|
              f.write line
            end  
          end
          @file_array <<  "#{request.subdomain}_1.csv"
        end  
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
