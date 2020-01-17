module Api
  module V2
    class DaysController < ApplicationController

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/days', "List of all days."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      ### => 'index' API Defination
      def index
        @days = Day.all
        rescue Exception => @error
        @log  = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      ### => API Documentation (APIPIE) for 'menu_mapping' action
      api :GET, '/api/v2/days/menu_mapping', "List of all menu mappings."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :day_id, String, :required => true, :desc => "Id of the day"
      param :unit_id, String, :required => true, :desc => "Id of the outlet"
      def menu_mapping
        @unit_id = params[:unit_id]
        if AppConfiguration.get_config_value('menu_merge') == 'enabled'
          @day = Day.find(params[:day_id])
          #@merge_sections = MenuMapping.select("DISTINCT(merge_section_id)").where(:day_id=> @day.id)
          @merge_sections = MenuMapping.select("DISTINCT(merge_section_id)").where(:day_id=> @day.id).by_unit_id(@unit_id)
        else
          @menu_merge_disabled = "Menu Merge module disabled."
        end  
        rescue Exception => @error
        @log  = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
