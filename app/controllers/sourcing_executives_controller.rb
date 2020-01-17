class SourcingExecutivesController < ApplicationController
	include SmartListing::Helper::ControllerExtensions
	helper  SmartListing::Helper
	def index  
    if params[:executive_name].present?
      @roll_arr = Array.new
      sale_person_role = Role.find_by_name("sourcing_exec")
      @roll_arr.push(sale_person_role.id)
      @sourcing_exec = User.set_role(@roll_arr).by_unit(current_user.unit.id).by_name(params[:executive_name]).uniq
    else  
      @roll_arr = Array.new
      sale_person_role = Role.find_by_name("sourcing_exec")
      @roll_arr.push(sale_person_role.id)
      if current_user.role.name == "bill_manager"
        #bill_manager_role = Role.find_by_name("bill_manager")
        #@roll_arr.push(bill_manager_role.id)
        @sourcing_exec = User.set_role(@roll_arr).by_unit(current_user.unit.id)
      elsif current_user.role.name == "owner"
        @sourcing_exec = User.set_role(@roll_arr)
      elsif current_user.role.name == "dc_manager"
        @sourcing_exec = User.set_role(@roll_arr)
      elsif current_user.role.name == "sourcing_exec"
        @sourcing_exec = User.by_id(current_user.id)    
      else
      	@sourcing_exec = User.set_role(@roll_arr).by_unit(current_user.unit.id)  
      end
	  end 
		# @sourcing_exec = Role.by_role_name("sourcing_exec").first
		# @sourcing_exec = @sourcing_exec.users
		# @sourcing_exec = User.find_by_name(@sourcing_exec,params[:executive_name]) if params[:executive_name].present?
		if params[:vendor_name].present?
			puts "vendor search for  #{params[:vendor_name]}"
			@vendors = Vendor.where("unit_id=?",@current_user.unit_id).vendor_like(params[:vendor_name])
		else
			@vendors = Vendor.where("unit_id=?",@current_user.unit_id)
		end
		smart_listing_create :sourcing_executives, @sourcing_exec, partial: "sourcing_executives/sourcing_executives_smartlist", default_sort: {created_at: "desc"},page_sizes:[15]
		smart_listing_create :vendors, @vendors, partial: "sourcing_executives/vendors_smartlist", default_sort: {created_at: "desc"}, page_sizes:[10]
	end

	def create_allocation
		if UserVendor.where("user_id=? and vendor_id=? and visit_date=?",params[:user_id],params[:vendor_id],params[:visit_date]).exists?
			respond_to do |format|
				format.json{render json:{status:"duplicate"}}
			end		
		else
			# @allocation=create_user_vendor(params[:user_id],params[:vendor_id],params[:visit_date])
			user_vendor  = UserVendor.create(:user_id=>params[:user_id] , :vendor_id=> params[:vendor_id] , :visit_date=>params[:visit_date])
			user_vendor.save
			respond_to do |format|
				format.json{render json:{status:"ok"}}
			end			
		end		
	end

	#recursive allocation function
	def create_recursive_allocation
		UserVendor.recursive_allocation(params[:visit_date],params[:duration],params[:user_id],params[:vendor_id],params[:recursion_rule])
		respond_to do |format|
			format.json{render json:{status:"ok"}}
		end
	end

	def get_allocations
		@allocate_data = UserVendor.where("user_id=?", params[:user_id])
		allocate_array = []
		@allocate_data.each do |allocation_data|
			event_hash = {}
			event_hash = {:title=> allocation_data.vendor.name , :start=> allocation_data.visit_date,:id=>allocation_data.id}
			allocate_array.push(event_hash)
		end
		respond_to do |format|
			format.json{render json:{data:allocate_array , status: "ok"}}
		end
	end

	def remove_allocation
		puts "parameters are #{params}"
		user_vendors = UserVendor.find(params[:id])
		event_id_array=[]
		if params[:from_date].present? and params[:to_date].present?
			event_id_array=UserVendor.where("user_id=? and vendor_id=? and visit_date BETWEEN ? AND ?",user_vendors.user_id,user_vendors.vendor_id,params[:from_date],params[:to_date]).pluck(:id)
			allocations = UserVendor.where("user_id=? and vendor_id=? and visit_date BETWEEN ? AND ?",user_vendors.user_id,user_vendors.vendor_id,params[:from_date],params[:to_date]).destroy_all
		else
			event_id_array.push(user_vendors.id)
			user_vendors.destroy
		end
		respond_to do |format|
			format.json{render json:{status:"ok",data:event_id_array}}
		end
	end

	def remove_all_by_date
		event_id_array=UserVendor.where("user_id=? and visit_date BETWEEN ? AND ?",params[:user_id],params[:from_date],params[:to_date]).pluck(:id)
		UserVendor.where("user_id=? and visit_date BETWEEN ? AND ?",params[:user_id],params[:from_date],params[:to_date]).destroy_all
		respond_to do |format|
			format.json{render json:{data:event_id_array,status:"ok"}}
		end
	end
	
	def update_allocation
		@update_allocation = UserVendor.find(params[:id])
		if UserVendor.where("user_id=? and vendor_id=? and visit_date=?",@update_allocation.user_id,@update_allocation.vendor_id,params[:visit_date]).present?
			respond_to do |format|
				format.json{render json:{status:"duplicate"}}
			end					
		else
			@update_allocation.update_column(:visit_date,params[:visit_date])
			respond_to do |format|
				format.json{render json:{data:@update_allocation,status:"ok"}}
			end
		end
	end

	def import
		begin
			ActiveRecord::Base.transaction do
				# redirect_to :back, notice: 'Resources are successfully imported with sale persons.'
				_error_message = []
				total_rows = 0
				if params[:file].present?
					file_name = params[:file].tempfile.to_path.to_s
					file_type = params[:file].original_filename.split('.')
					raise "File format must be csv." unless file_type.last == "csv"
		      total_rows = CSV.foreach(params[:file].path, headers: true).count
		      if total_rows <= 500
		      	CSV.foreach(params[:file].path,headers:true) do |csv_row|
		      		_error = validate_csv_data(csv_row)
		      		if !_error.blank?
		      			_error_message.push _error
		      		end
		      	end
		      else
		      	_error_message.push "Number of Records must not exceed 500"
		      end
			    if !_error_message.blank?
						_error_message.push("please check the sheet again")
						redirect_to :back, alert: _error_message.join(",")
					else
						UserVendor.import(params[:file])
						redirect_to :back, notice: "Vendor allocation successful"
					end 
				end	
			end
		rescue Exception => e
			puts e.message
	    flash[:error] = e.message
	    redirect_to :back
	  end
	end
	def validate_csv_data(csv_row)
		_error=[]
		_user = User.find_by_email(csv_row["Email"])
		_vendor = Vendor.where("unit_id=? and id=?",@current_user.unit_id, csv_row["Vendor_id"])
		_error.push "User #{csv_row["Email"]} does not exist." unless _user.present?
		_error.push "vendor id #{csv_row["Vendor_id"]} does  not  exist." unless  _vendor.present?
		_error.push "date #{csv_row["Visit_date"]} is older than current date" unless csv_row["Visit_date"].to_date >= Date.today
		return _error
	end

	
	def sample_csv
		@allocation = UserVendor.limit(5)
		respond_to do |format|
			format.csv {send_data UserVendor.generate_sample_csv(@allocation),filename:"sample_bulk_allocation.csv"}
		end
	end

	def vendor_inspections

		@vendors = Vendor.where("unit_id=?",@current_user.unit_id)
		@roll_arr = Array.new
    sourcing_exec_role = Role.find_by_name("sourcing_exec")
    @roll_arr.push(sourcing_exec_role.id)
    if current_user.role.name == "bill_manager"
      @sourcing_executives = User.set_role(@roll_arr).by_unit(current_user.unit.id)
      @vendors = Vendor.by_unit(current_user.unit.id)
    elsif current_user.role.name == "owner"
      @sourcing_executives = User.set_role(@roll_arr)
      @vendors = Vendor.all
    elsif current_user.role.name == "dc_manager"
      @sourcing_executives = User.set_role(@roll_arr)
      @vendors = Vendor.all 
    elsif current_user.role.name == "sourcing_exec"
      @sourcing_executives = User.by_id(current_user.id)    
      @vendors = Vendor.by_unit(current_user.unit.id)
    else
      @sourcing_executives = User.by_id(current_user.id) 
    end
    @vendor_inspections = Inspection.by_unit(@current_user.unit_id).set_inspected_entity_type('Vendor').order('id desc')
    puts @sourcing_executives.inspect
    if params[:user_filter].present? 
      @sourcing_executives = @sourcing_executives.by_name(params[:user_filter])
      _user_ids = @sourcing_executives.uniq.pluck(:id)
      @vendor_inspections = @vendor_inspections.set_user_in(_user_ids)
    end
		@vendor_inspections = @vendor_inspections.joins("INNER JOIN vendors ON inspections.inspected_entity_id = vendors.id").merge(Vendor.vendor_like(params[:vendor_filter])) if params[:vendor_filter].present?

    smart_listing_create :vendor_inspections, @vendor_inspections, partial: "sourcing_executives/vendor_inspections_smartlist",page_sizes:[10]
    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      # format.json { render json: @inspections }
      format.json { render json: @sourcing_executives }
    end

	end

end