class CustomersController < ApplicationController
  require 'smarter_csv'
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.reverse
    @customers = @customers.search(params[:id_filter]) if params[:id_filter].present?
    @customers = @customers.search_resource(params[:resource_filter]) if params[:resource_filter].present?
    smart_listing_create :customers, @customers, partial: "customers/customer_list"
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  # def show
  #   @customer = Customer.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @customer }
  #   end
  # end

  def show
    @customer = Customer.find(params[:id])
    if @customer.wallet.present?
      @wallet_transactions = @customer.wallet.wallet_transactions
    else
      @wallet_transactions = ""
    end  
    respond_to do |format|
      format.html
      format.json { render json: {customer: @customer, transactions: @wallet_transactions}}
    end
  end

  def find
    @customer = Customer.by_identification(params[:login]).first
    respond_to do |format|
      format.js
    end
  end

  # GET /customers/new
  # GET /customers/new.json
  # def new
  #   @customer = Customer.new
  #   @customer_profile = @customer.build_customer_profile
  #   @address = @customer.addresses.build

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @customer }
  #   end
  # end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
    @address = @customer.addresses.first
    @sections = Section.where(:unit_id => current_user.unit_id)
    @resource_states = ResourceState.all
    @resource_types = ResourceType.all
  end

  # POST /customers
  # POST /customers.json
  # def create
  #   @customer = Customer.new(params[:customer])

  #   respond_to do |format|
  #     if @customer.save
  #       format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
  #       format.json { render json: @customer, status: :created, location: @customer }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @customer.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def new
    @customer = Customer.new
    #@customer_profile = @customer.build_customer_profile
    @address = @customer.addresses.build
    @sections = Section.where(:unit_id => current_user.unit_id)
    @resource_states = ResourceState.all
    @resource_types = ResourceType.all
  end

  def create
    @customer = Customer.new(params[:customer])
    @customer.password = "12345678"
    # puts @customer.errors.full_messages
    respond_to do |format|
      if @customer.save 
        UnitCustomer.save_unit_customers(@customer.id, params['unit_ids']) if params['unit_ids'].present?  
        format.html { redirect_to customers_url, notice: 'Customer was successfully Created.' }
        format.js
        format.json { render json: @customer.to_json(:include => :profile) }
      else
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity } 
      end  
    end  
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @customer = Customer.find(params[:id])
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        UnitCustomer.save_unit_customers(@customer.id, params['unit_ids']) if params[:unit_ids].present?
        format.html { redirect_to customers_url, notice: 'Customer was successfully Updated.' }
        format.js
        format.json { render json: @customer.to_json(:include => :profile) }
      else
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }  
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url }
      format.json { head :no_content }
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
          total_rows = CSV.foreach(params[:file].path, headers: true).count
          if total_rows < 1001
            row_no = 2
            CSV.foreach(params[:file].path, headers: true) do |csv_row|
              _errors = validate_customer(csv_row,row_no)
              if !_errors.blank?
                error_message.push _errors
              end
              row_no+=1
            end
          else
            error_message.push "No. of rows should be less than 1000."
          end
        end
        if !error_message.blank?
          redirect_to :back, alert: error_message.join("<br />")
        else
          Customer.import(params[:file])
          redirect_to :back, notice: 'Customers was successfully imported.'
        end  
      end      
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def customer_params
      params.require(:customer).permit(:email, :mobile_no)
    end

    def validate_customer(_header,row_no)
      _errors = []
      _mobile_no = _header["Mobile No"] || ''
      _first_name = _header["First Name"] || ''
      _last_name = _header["Last Name"] || ''
      _unit_name = _header["Unit Name"] || ''
      _section_name = _header["Section Name"] || ''
      _resource_name = _header["Resource Name"] || ''
      _resource_type = _header["Resource Type"] || ''
      _unique_identity_no = _header["Unique Identity No"] || ''
      _beat_name = _header["Beat Name"] || ''
      if _header["Unit Name"].present?
        _unit = Unit.by_unit_name(_header["Unit Name"])
        _errors.push "Unit not found with Unit Name: #{_header["Unit Name"]}." unless _unit.present?
      end
      if _mobile_no.length == 0
        _errors.push "Mobile No missing in line no :#{row_no}."
      elsif _first_name.length == 0
        _errors.push "First Name missing in line no :#{row_no}." 
      elsif _last_name.length == 0
        _errors.push "Last Name missing in line no :#{row_no}."
      # elsif _unique_identity_no.length == 0
      #   _errors.push "unique identity no is missing :#{row_no}."
      elsif _section_name.length == 0
        _errors.push "section name is missing :#{row_no}."
      elsif _resource_name.length == 0
        _errors.push "resource name is missing :#{row_no}."
      elsif _unit_name.length == 0
        _errors.push "unit name is missing :#{row_no}."
      elsif _resource_type.length == 0
        _errors.push "resource type is missing :#{row_no}."
      else
        if (10..12).include?(_mobile_no.length)
          _customer = Customer.by_identification(_mobile_no) if _mobile_no.present? 
          _errors.push "Mobile No : #{_mobile_no} already exist." if _customer.present?
          _email_customer = Customer.by_identification(_header["Email"]) if _header["Email"].present?
          _errors.push "Email :#{_header["Email"]} already exist." if _email_customer.present?
          _resource_unique_identity_no = Resource.by_unique_identity_no(_header["Unique Identity No"]) if _header["Unique Identity No"].present?
          _errors.push "Unique Identity No: #{_header["Unique Identity No"]} already exist." if _resource_unique_identity_no.present? 
          _section_name = Section.by_section_name(_header["Section Name"]) if _header["Section Name"].present?
          _errors.push "section name: #{_header["Section Name"]} not exist." unless _section_name.present?
          # _resource_name = Resource.name_like(_header["Resource Name"]).first.resource_state.id if _header["Resource Name"].present?
          # _errors.push "resource name: #{_header["Resource Name"]} not exist." unless _resource_name.present?
          _unit_name = Unit.by_unit_name(_header["Unit Name"]) if _header["Unit Name"].present?
          _errors.push "unit name: #{_header["Unit Name"]} not exist." unless _unit_name.present?
          _resource_type = ResourceType.by_resource_type_name(_header["Resource Type"]) if _header["Resource Type"].present?
          _errors.push "resource type: #{_header["Resource Type"]} not exist." unless _resource_type.present?
          # _beat_name = Bit.by_bit_name(_header["Bit Name"]) if _header["Bit Name"].present?
          # _errors.push "Beat name: #{_header["Bit Name"]} not exist." unless _beat_name.present?
        else
          _errors.push "Mobile No Must be 10 to 12 Digit in line no :#{row_no}."
        end
      end  
      return _errors
    end   

end
