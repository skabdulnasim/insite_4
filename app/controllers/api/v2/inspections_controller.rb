module Api
	module V2
		class InspectionsController < ApplicationController
			
			def create
				ActiveRecord::Base.transaction do
					@inspections = Inspection.new(params[:inspections])
					if @inspections.save
						@inspections.update_attributes(:image=>params[:image]) if params[:image].present?
					end
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

			def show
				ActiveRecord::Base.transaction do
					@inspection = Inspection.find(params[:id])
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end

		end
	end
end