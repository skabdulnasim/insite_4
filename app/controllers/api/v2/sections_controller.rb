module Api
  module V2
    class SectionsController < ApplicationController 
      def show
        @section = Section.find(params[:id])
        rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def section_tax_groups
      	@tax_groups = Unit.find(params[:unit_id]).sections.by_section_type('sourcing').first.tax_groups
      	rescue Exception => @error          
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

    end
  end
end