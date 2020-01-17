class PackagesController < ApplicationController
	
	def index
		@packges  = Package.order("id desc")
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
	end

	def new

	end

	def show
		@package = Package.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
	end

	def edit
		
	end

	def search_package_components
    render json: PackageComponent.name_for(params[:term])
  end
	
end