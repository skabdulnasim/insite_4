class SalesPersonsController < ApplicationController
	load_and_authorize_resource :except => [:allot_resource, :allot_resource_map, :delete_user_resource, :create_allocation, :get_allocations, :remove_allocation, :remove_all_by_date, :update_allocation, :create_recursive_allocation, :sample_csv, :import, :validate_sales_person]
	layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include ApplicationHelper

	def index
		@roll_arr = Array.new
	  sale_person_role = Role.find_by_name("sale_person")
	  @roll_arr.push(sale_person_role.id)
	  units = Array.new
	  units.push(current_user.unit_id)
	  unit_arr = child_units(units,current_user.unit)
	  puts "child units : #{unit_arr}"
		@users = User.set_role(@roll_arr).set_unit(unit_arr).by_status(1).order(:unit_id)
		@resources = Resource.by_unit_list(unit_arr).active_only

		@users = @users.by_name(params[:sale_person_name]).uniq if params[:sale_person_name].present?
		@resources = @resources.filter_by_string(params[:resource_name]) if params[:resource_name].present?
		
		smart_listing_create :user_list, @users, partial: "sales_persons/user_list",page_sizes:[10]
		smart_listing_create :resource_list, @resources, partial: "sales_persons/resource_list",page_sizes:[10]
		smart_listing_create :bits_list, Bit.order("id ASC"), partial: "sales_persons/bits_list", page_sezes:[10]
		respond_to do |format|
      format.html
      format.js
	   end
	end

	def allot_resource
		@user_resources = UserResource.new()
		@user_resources.day = params["day"]
		@user_resources.user_id = params["user_id"]
		@user_resources.resource_id = params["resource_id"]
		@user_resources.save
		respond_to do |format|
			format.json { render json: @user_resources }
		end	
	end

	def allot_resource_map
		params["selected_respurces"].each do |resource_id|
			_user_id = params["allocat_to"]
			_visit_date = params["allocation_date"]
			_count = UserResource.fetch_duplicate_allocation(_user_id,resource_id,_visit_date).count
			if _count == 0
				@user_resources = UserResource.new()
				@user_resources.user_id = _user_id
				@user_resources.resource_id = resource_id
				@user_resources.visit_date = _visit_date
				@user_resources.save
			end
		end
		respond_to do |format|
      format.html { redirect_to :back, notice: 'Resources are successfully allocated.' }
    end    
	end

	def delete_user_resource
    @user_resource = UserResource.find(params[:user_resource_id])
    @user_resource.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def create_allocation
  	## for bit allocation
  	if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
  		allocate_user_bit(params[:user_id],params[:resource_id],params[:visit_date])
		## for resource allocation
  	else
			if UserResource.where("user_id=? and resource_id=? and visit_date=?",params[:user_id],params[:resource_id],params[:visit_date]).exists?
				respond_to do |format|
					format.json{render json:{status:"duplicate"}}
				end		
			else
				user_resource  = UserResource.create(:user_id=>params[:user_id] , :resource_id=> params[:resource_id] , :visit_date=>params[:visit_date])
				user_resource.save
				respond_to do |format|
					format.json{render json:{status:"ok"}}
				end			
			end	
		end	
	end

  def get_allocations
  	puts params
  	allocate_array = []  	
  	if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
  		@allocate_data = UserBit.where("user_id=?", params[:user_id]) ## get bit allocations
  		@allocate_data.each do |allocation_data|
				event_hash = {}
				if allocation_data.visit_date.present?
					event_hash = {:title=> allocation_data.bit.name , :start=> allocation_data.visit_date,:id=>allocation_data.id}
					allocate_array.push(event_hash)
				end
			end
  	else
	  	@allocate_data = UserResource.where("user_id=?", params[:user_id]).includes(:resource)## get resource allocations
	  	@allocate_data.each do |allocation_data|
				event_hash = {}
				if allocation_data.visit_date.present?
					event_hash = {:title=> allocation_data.resource.name , :start=> allocation_data.visit_date,:id=>allocation_data.id} if allocation_data.resource.present?
					allocate_array.push(event_hash) if event_hash.present?
				end
			end
	  end
		respond_to do |format|
			format.json{render json:{data:allocate_array , status: "ok"}}
		end
  end
  
	def remove_allocation ## remove allocations within/without date range for a particular resource_id
		if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
			remove_user_bits(params[:id])
		else
			user_resource = UserResource.find(params[:id])
			event_id_array=[]
			if params[:from_date].present? and params[:to_date].present?
				event_id_array=UserResource.where("user_id=? and resource_id=? and visit_date BETWEEN ? AND ?",user_resource.user_id,user_resource.resource_id,params[:from_date],params[:to_date]).pluck(:id)
				allocations = UserResource.where("user_id=? and resource_id=? and visit_date BETWEEN ? AND ?",user_resource.user_id,user_resource.resource_id,params[:from_date],params[:to_date]).destroy_all
			else
				event_id_array.push(user_resource.id)
				user_resource.destroy
			end
			respond_to do |format|
				format.json{render json:{status:"ok",data:event_id_array}}
			end
		end
	end

	def remove_all_by_date ##remove every allocation within a  date range
		if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
			remove_user_bits_by_date(params[:user_id],params[:from_date],params[:to_date])
		else
			event_id_array=UserResource.where("user_id=? and visit_date BETWEEN ? AND ?",params[:user_id],params[:from_date],params[:to_date]).pluck(:id)
			UserResource.where("user_id=? and visit_date BETWEEN ? AND ?",params[:user_id],params[:from_date],params[:to_date]).destroy_all
			respond_to do |format|
				format.json{render json:{data:event_id_array,status:"ok"}}
			end
		end
	end

	def update_allocation
		if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
			update_user_bits(params[:id],params[:visit_date])
		else
			@user_resource = UserResource.find(params[:id])
			if UserResource.where("user_id=? and resource_id=? and visit_date=?",@user_resource.user_id,@user_resource.resource_id,params[:visit_date]).present?
				respond_to do |format|
					format.json{render json:{status:"duplicate"}}
				end					
			else
				@user_resource.update_column(:visit_date,params[:visit_date])
				respond_to do |format|
					format.json{render json:{data:@user_resource,status:"ok"}}
				end
			end			
		end
	end

	#recursive allocation method
	def create_recursive_allocation
		if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
		else
			UserResource.recursive_allocation(params[:visit_date],params[:duration],params[:user_id],params[:resource_id],params[:recursion_rule])
		end
		respond_to do |format|
			format.json{render json:{status:"ok"}}
		end
	end

	def sample_csv
		_user_resource = UserResource.limit(10)
		respond_to do |format|
			format.csv {send_data UserResource.sample_csv(_user_resource),filename:"sample_bulk_resource_allocation.csv"}
		end
	end

	def import
	  begin
	    ActiveRecord::Base.transaction do
	      total_rows = 0
	      error_message = []
	      if params[:file].present?
	        file_name = params[:file].tempfile.to_path.to_s
	        file_type = params[:file].original_filename.split('.')
	        raise "File format should be csv." unless file_type[1] == "csv"
	        # total_rows = CSV.read(params[:file].path).count
	        total_rows = CSV.foreach(params[:file].path, headers: true).count
	        if total_rows < 501
	          CSV.foreach(params[:file].path, headers: true) do |csv_row|
	            _errors = validate_sales_person(csv_row)
	            if !_errors.blank?
	              error_message.push _errors
	            end
	          end
	        else
	          error_message.push "No. of rows should be less than 500."
	        end
	      end
	      if !error_message.blank?
	        redirect_to :back, alert: error_message.join(",")
	      else
	        UserResource.import(params[:file])
	        redirect_to :back, notice: 'Resources are successfully imported with sale persons.'
	      end
	    end
	  rescue Exception => e
	    flash[:error] = e.message
	    redirect_to :back, alert: 'Exception.'
	  end
	end

  def validate_sales_person(csv_row)
  	_error=[]
  	if !csv_row["Email"].present? or !csv_row["Resource_id"].present? or !csv_row["Visit_date"].present?
  		_error.push "one or more field missing"
  		return _error
  	else
	  	_user = User.find_by_email(csv_row["Email"])
			_resource = Resource.where("unit_id=? and id=?",@current_user.unit_id, csv_row["Resource_id"])
			_error.push "User #{csv_row["Email"]} does not exist." unless _user.present?
			_error.push "Resource id #{csv_row["Vendor_id"]} does  not  exist." unless  _resource.present?
			_error.push "date #{csv_row["Visit_date"]} is older than current date" unless csv_row["Visit_date"].to_date >= Date.today
			return _error
  	end
  end

  private
 	
 	## *starting sale person  bit allocation module 

 	def allocate_user_bit(user_id,resource_id,visit_date)
 		if UserBit.where("user_id=? and bit_id=? and visit_date=?",user_id,resource_id,visit_date).exists?
				respond_to do |format|
					format.json{render json:{status:"duplicate"}}
				end		
		else
			user_bit  = UserBit.create(:user_id=>user_id , :bit_id=> resource_id , :visit_date=>visit_date)
			user_bit.save
			respond_to do |format|
				format.json{render json:{status:"ok"}}
			end			
		end	
 	end

  def update_user_bits(id,visit_date)
		_user_bit = UserBit.find(id)
		if UserBit.where("user_id=? and bit_id=? and visit_date=?",_user_bit.user_id,_user_bit.bit_id,visit_date).present?
			respond_to do |format|
				format.json{render json:{status:"duplicate"}}
			end					
		else
			_user_bit.update_column(:visit_date,visit_date)
			respond_to do |format|
			format.json{render json:{data:_user_bit,status:"ok"}}
			end
		end	
 	end

  def remove_user_bits(user_bit_id)
  	user_bit= UserBit.find(user_bit_id)
		event_id_array=[]
		if params[:from_date].present? and params[:to_date].present?
			event_id_array=UserBit.where("user_id=? and bit_id=? and visit_date BETWEEN ? AND ?",user_bit.user_id,user_bit.bit_id,params[:from_date],params[:to_date]).pluck(:id)
			allocations = UserBit.where("user_id=? and bit_id=? and visit_date BETWEEN ? AND ?",user_bit.user_id,user_bit.bit_id,params[:from_date],params[:to_date]).destroy_all
		else
			event_id_array.push(user_bit.id)
			user_bit.destroy
		end
		respond_to do |format|
			format.json{render json:{status:"ok",data:event_id_array}}
		end
  end

  def remove_user_bits_by_date(user_id,from_date,to_date)
		event_id_array=UserBit.where("user_id=? and visit_date BETWEEN ? AND ?",user_id,from_date,to_date).pluck(:id)
		UserBit.where("user_id=? and visit_date BETWEEN ? AND ?",user_id,from_date,to_date).destroy_all
		respond_to do |format|
			format.json{render json:{data:event_id_array,status:"ok"}}
		end
  end
  ## *ending sale person bit allocation module  
end