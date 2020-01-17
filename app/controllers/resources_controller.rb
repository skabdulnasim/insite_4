class ResourcesController < ApplicationController
  layout "material"
  
  before_filter :set_module_details
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  # GET /resources
  # GET /resources.json
  def index
    _current_outlet = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @sections = Section.unit_sections(_current_outlet)
    @resources = Resource.order('id desc').get_root_resources
    @resources = @resources.by_unit(_current_outlet)
    @resources = @resources.by_section(params[:section_id]) if params[:section_id].present?
    @resources = @resources.by_resource_type(params[:resource_type]) if params[:resource_type].present?
    @resources = @resources.name_like(params[:name_filter]) if params[:name_filter].present?
    smart_listing_create :resources, @resources.active_only, partial: "resources/resources_smartlist", default_sort: {id: "desc"}
    smart_listing_create :disabled_resources, @resources.disabled, partial: "resources/disabled_resources_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @resources }
    end
  end

  # GET /resources/1
  # GET /resources/1.json
  # def show
  #   @resource = Resource.find(params[:id])
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @resource }
  #     format.js
  #   end
  # end

  def show
    @month = Date.today.strftime("%m")
    @year = Date.today.strftime("%Y")
    @month = params[:date][:month] if params[:date].present?
    @year = params[:date][:year] if params[:date].present?
    @resource = Resource.find(params[:id])
    @products = Product.order('created_at desc')
    @tagret_products = Array.new
    @tagret_products = Kaminari.paginate_array(@tagret_products)
    @targets = ResourceTarget.by_month_range(@month,@month).by_year_range(@year,@year).set_resource(@resource.id)
    @tagret_products = @targets.first.user_target_products if @targets.present?
    smart_listing_create :targets, @tagret_products, partial: "resources/targets_smartlist"
    smart_listing_create :products, @products, partial: "resources/products_smartlist"
    smart_listing_create :benefisiaries, @resource.beneficiaries, partial: "resources/beneficiaries_smartlist"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource }
      format.js
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
    @resource = Resource.new(resource_type_id: params['resource_type_id'], unit_id: current_user.unit_id)
    @sections = Section.where(:unit_id => current_user.unit_id)
    @customers = Customer.by_unit(current_user.unit_id)
    @resources = Resource.order("name")
    @resource_states = ResourceState.all
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
    @resource_states = ResourceState.all
    @customers = Customer.by_unit(current_user.unit_id)
    @sections = Section.where(:unit_id => current_user.unit_id)
    @resources = Resource.order("name")
    @menu_cards = MenuCard.set_section(@resource.section_id).active
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])

    respond_to do |format|
      if @resource.save
        format.html { redirect_to resources_path, notice: 'Resource was successfully created.' }
        format.json { render json: @resource, status: :created, location: @resource }
      else
        format.html { render action: "new" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to resources_path, notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def fetch_active_menu_cards
    @menu_cards = MenuCard.set_section(params[:section_id]).active

    respond_to do |format|
      format.json { render :json => @menu_cards}
    end
  end

  def fetch_section_resources
    @resources = Section.find(params[:section_id]).resources.get_root_resources
    puts @resources.inspect
    respond_to do |format|
      format.json { render :json => @resources}
    end
  end

  def fetch_active_menu_products
    @menu_products = MenuCard.find(params[:menu_card_id]).menu_products
    respond_to do |format|
      format.json { render json: @menu_products.to_json(:include => :product) }
    end
  end

  def remove_resource_product
    @resource = Resource.find(params[:id])
    _product = @resource.resource_products.by_product(params[:product_id]).first
    _product.destroy
    respond_to do |format|
      format.html{redirect_to resource_path(params[:id]), notice: 'Product was successfully deleted.'}
      format.json {head:no_content}
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def find
    @resource = Resource.by_identification(params[:resource_search_key]).first
    respond_to do |format|
      format.js
    end
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/resources/change_resource_state.json', "Change a resource status"
    error :code => 401, :desc => "Unauthorized"
    param :resource_id, String, :desc => "Resource ID", :required => true
    param :user_id, String, :desc => "User ID", :required => true
    param :unit_id, String, :desc => "Outlet ID", :required => true
    param :resource_state_id, String, :desc => "State ID, to which you want to change the Resource state", :required => true
    description "Change the resource state of an outlet to : Empty, Occupied, Served, Reserved, Not Settled, Out of Order"
    formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def change_resource_state
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        @status_log = Resource.update_resource_state(params[:resource_state_id],params[:unit_id],params[:resource_id],params[:user_id],params[:device_id])
      end
      respond_to do |format|
        format.json { render json: @status_log }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: [{:error => e.message.to_s}] }
      end
    end
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
    api :POST, '/resources/swap_resource.json', "Swap resource orders"
    error :code => 401, :desc => "Unauthorized"
    param :old_resource_id, String, :desc => "Old Resource ID", :required => true
    param :new_resource_id, String, :desc => "New Resource ID", :required => true
    param :unit_id, String, :desc => "Unit ID", :required => true
    param :user_id, String, :desc => "User ID", :required => true
    param :order_ids, String, :desc => "Order IDs is JSON formats, which will be swapped to new resource, [{'order_id':'3'},{'order_id':'4'},{'order_id':'5'}]", :required => true
    description "Transfer orders from one resource to another, (Resource SWAP)."
    formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def swap_resource
    begin
      ActiveRecord::Base.transaction do # Protective transaction block
        _order_ids = JSON.parse(params[:order_ids])
        _old_resource = Resource.find(params[:old_resource_id])
        _new_resource = Resource.find(params[:new_resource_id])
        Resource.swap_resource_orders _order_ids, _new_resource, _old_resource, params[:device_id], params[:user_id], params[:unit_id]
      end
    rescue Exception => @error
      Rscratch::Exception.log @error,request
    end
  end

  def get_resources
    @resources = Resource.get_status(params[:section_id],params[:resource_state_id])
    respond_to do |format|
      format.json { render json: @resources }
    end
  end

  def retail_shops_list
    # @roll_arr = Array.new
    # sale_person_role = Role.find_by_name("sale_person")
    # @roll_arr.push(sale_person_role.id) if sale_person_role.present?
    # if current_user.role.name == "bill_manager"
    #   @resources = Resource.active_only.by_unit(current_user.unit.id)
    # elsif current_user.role.name == "owner"
    #   @resources = Resource.active_only
    # elsif current_user.role.name == "dc_manager"
    #   @resources = Resource.active_only
    # elsif current_user.role.name == "sale_person"
    #   @resources = Resource.active_only.by_unit(current_user.unit.id)
    # else
    #   @resources = Resource.active_only.by_unit(current_user.unit.id)  
    # end
    @resources = get_user_resources(current_user.id)
    @resources = @resources.name_like(params[:name_filter]) if params[:name_filter].present?
    smart_listing_create :retail_shops, @resources, partial: "resources/retail_shops_smartlist"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @resources }
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
              _errors = validate_resources(csv_row,row_no)
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
          Resource.import(params[:file],current_user.id)
          redirect_to :back, notice: 'Resources was successfully imported.'
        end  
      end      
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  def sample_commission_csv
    respond_to do |format|
      format.csv {send_data CommissionRule.sample_commission_csv,filename:"sample_commission_allocation.csv"}
    end
  end

  def import_commission
    begin 
      ActiveRecord::Base.transaction do
        _error_message=[]
        if params[:file].present?
          puts params[:file].original_filename
          file_type=params[:file].original_filename.split('.')
          raise "File format must be csv." unless file_type.last == "csv"
          puts "File format must be csv"
          total_rows = CSV.foreach(params[:file].path,headers:true).count
          puts "csv error"
          if total_rows > 500
            _error_message.push "Number of rows must not exceed 500"
          end
          if !_error_message.blank?
            puts "Errors are there"
            _error_message.push("Please check the sheet again.")
            redirect_to :back, alert: _error_message.join(",")
          else
            result = validate_commission_csv(params[:file])
            if result.blank?
              insert_commission_bulk(params[:file])
              redirect_to :back, notice: " commission successfully uploaded"
            else
              _error_message.push(result)
              redirect_to :back, alert: _error_message.join(",")
            end
          end
        end
      end
    rescue Exception => e
      flash[:error]=e.message
      redirect_to :back
      puts e.message
    end
  end

  def import_beneficiary
    begin 
      ActiveRecord::Base.transaction do
        _error_message=[]
        if params[:file].present?
          puts params[:file].original_filename
          file_type=params[:file].original_filename.split('.')
          raise "File format must be csv." unless file_type.last == "csv"
          puts "File format must be csv"
          total_rows = CSV.foreach(params[:file].path,headers:true).count
          puts "csv error"
          if total_rows > 500
            _error_message.push "Number of rows must not exceed 500"
          end
          if !_error_message.blank?
            puts "Errors are there"
            _error_message.push("Please check the sheet again.")
            redirect_to :back, alert: _error_message.join(",")
          else
            result = validate_beneficiary_csv(params[:file])
            if result.blank?
              insert_beneficiary_bulk(params[:file])
              redirect_to :back, notice: " Beneficiary successfully uploaded"
            else
              _error_message.push(result)
              redirect_to :back, alert: _error_message.join(",")
            end
          end
        end
      end
    rescue Exception => e
      flash[:error]=e.message
      redirect_to :back
      puts e.message
    end
  end

  def export_resource
    _current_outlet = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @resources = Resource.by_unit(_current_outlet)
    respond_to do |format|
      format.html
      format.csv { send_data Resource.dump_to_csv(@resources), filename: "user_resource-#{Date.today}.csv" }
    end
  end

  def validate_commission_csv(file)
    puts "validate_commission_csv"
    error=[]
    i=0
    CSV.foreach(file.path,headers:true) do |row|
      i+=1
      if !row["Resource id"].present? or !row["Month"].present? or !row["Set By"].present? or !row["Product"].present? or !row["Amount type"].present? or !row["Amount"].present?
        error.push("some mandatory field are missing in the sheet at row number: #{i}")
      elsif !Product.find_by_name(row["Product"]).present?
        error.push("product #{row["Product"]} does not exist")
      elsif !User.by_email(row["Set By"]).present?
        error.push("Email #{row["Set By"]} does not exist")
      elsif !Resource.find(row["Resource id"]).present?
        error.push("Resource id #{row["Resource id"]} does not exist")
      end
    end
    return error
  end

  def validate_beneficiary_csv(file)
    error=[]
    i=0
    CSV.foreach(file.path,headers:true) do |row|
      i+=1
      if !Resource.find(row["Resource id"]).present?
        error.push("Resource with id: #{row["Resource id"]} does not exist")
      end
      # if !row["Resource id"].present? or !row["Beneficiary Name"].present? or !row["Beneficiary Type"].present? or !row["Bank Name"].present? or !row["Branch Name"].present? or !row["Account Number"].present? or !row["Ifsc Code"].present? or !row["Payment Mode"].present?
      #   error.push("some mandatory field are missing in the sheet at row number: #{i}")
      # elsif !Resource.find(row["Resource id"]).present?
      #   error.push("Resource with id: #{row["Resource id"]} does not exist")
      # end
    end
    return error
  end

  def insert_commission_bulk(csv_file)
    CSV.foreach(csv_file.path, headers:true) do |row|
      _product_id = Product.find_by_name(row["Product"]).id
      commission_rules = CommissionRule.by_resource(row["Resource id"]).by_month(row["Month"])
      if commission_rules.present?
        commission_rule_id = commission_rules.first.id
        commission_rule_input = CommissionRuleInput.find_by_product_id_and_commission_rule_id(_product_id,commission_rule_id)
        if commission_rule_input.present?
          commission_rule_output = CommissionRuleOutput.find_by_commission_rule_input_id(commission_rule_input.id)
          commission_rule_output.update_attributes(:amount=> row["Amount"], :amount_type=> row["Amount type"], :owner_commission_amount=> row["Owner commission amount"], :csm_commission_amount=> row["Csm commission amount"])
        else
          commission_hash = {
              :resource_id=> row["Resource id"],
              :month=> row["Month"],
              :set_by=> User.by_email(row["Set By"]).first.id,
              :commission_rule_inputs_attributes=>[
                {
                  :product_id=> Product.find_by_name(row["Product"]).id,
                  :commission_rule_output_attributes=>{
                    :amount=> row["Amount"],
                    :amount_type=> row["Amount type"],
                    :owner_commission_amount=> row["Owner commission amount"],
                    :csm_commission_amount=> row["Csm commission amount"]
                  }
                }
              ]
            }
          _commission = CommissionRule.new(commission_hash)
          _commission.save
        end
      else
        commission_hash = {
              :resource_id=> row["Resource id"],
              :month=> row["Month"],
              :set_by=> User.by_email(row["Set By"]).first.id,
              :commission_rule_inputs_attributes=>[
                {
                  :product_id=> Product.find_by_name(row["Product"]).id,
                  :commission_rule_output_attributes=>{
                    :amount=> row["Amount"],
                    :amount_type=> row["Amount type"],
                    :owner_commission_amount=> row["Owner commission amount"],
                    :csm_commission_amount=> row["Csm commission amount"]
                  }
                }
              ]
            }
        _commission = CommissionRule.new(commission_hash)
        _commission.save
      end
    end
  end

  def insert_beneficiary_bulk(csv_file)
    CSV.foreach(csv_file.path, headers:true) do |row|
      if row["Account Number"].present?
        beneficiary_hash = {
              :resource_id=> row["Resource id"],
              :account_number=> row["Account Number"],
              :bank_name=> row["Bank Name"],
              :ifsc => row["Ifsc Code"],
              :name => row["Beneficiary Name"],
              :payment_mode => row["Payment Mode"],
              :branch => row["Branch Name"],
              :beneficiary_type => row["Beneficiary Type"],
              :pan_no => row["Pan NO"],
              :status => true,
              :beneficiary_percentage => row["Beneficiary Percentage"]
            }
        _beneficiary = Beneficiary.new(beneficiary_hash)
        _beneficiary.save
      end  
    end
  end

  private
    def set_module_details
      @module_id = "Resource"
      @module_title = "Resource"
    end

    def validate_resources(_header,row_no)
      _errors = []
      _mobile_no = _header["Customer Mobile No"] || ''
      _resource_name = _header["Resource Name"] || ''
      _section_name = _header["Section Name"] || ''
      _resource_type = _header["Resource Type"] || ''
      if _resource_name.length == 0
        _errors.push "Resource Name missing in line no :#{row_no}."
      end  
      if _section_name.length == 0
        _errors.push "Section Name missing in line no :#{row_no}."  
      else
        _section = Section.by_section_name(_header["Section Name"])
        _errors.push "Section not found with Section Name in line no :#{row_no}" unless _section.present?
      end  
      if _resource_type.length == 0
        _errors.push "Resource Type missing in line no :#{row_no}."  
      else
        _resource_type = ResourceType.by_resource_type_name(_header["Resource Type"])
        _errors.push "Resource Type not found with Resource Type in line no :#{row_no}" unless _resource_type.present?
      end  
      if _header["Bit Name"].present?
        _bits = Bit.by_bit_name(_header["Bit Name"])
        _errors.push "Bit not found with Bit name in line no :#{row_no}" unless _bits.present?
      end
      if _header["Unique Identity No"].present?
        _unique_identity = Resource.by_unique_identity(_header["Unique Identity No"])
        _errors.push "Resource present with this Unique Identity No in line no :#{row_no}" if _unique_identity.present?
      end           
      if _mobile_no.length != 0
        if (10..12).include?(_mobile_no.length)
          _customer = Customer.by_identification(_mobile_no) if _mobile_no.present? 
          _errors.push "Customer not found with mobile no :#{_mobile_no} in line no :#{row_no}." unless _customer.present?
        else
          _errors.push "Mobile No Must be 10 to 12 Digit in line no :#{row_no}."
        end
      end  
      return _errors
    end
end
