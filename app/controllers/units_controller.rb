class UnitsController < ApplicationController
  load_and_authorize_resource :except => [:fetch_unit_details, :fetch_units, :fetch_drop, :fetch_unit_type]
  layout "material"

  before_filter :set_module_details

  require 'rest-client'
  require 'json'
  require 'date'

  def index
    #@units = Unit.paginate(:page => params[:page]).order('id DESC')
    @units = Unit.order('id')
    @units = @units.set_city(params[:city]) if params[:city].present?
    @unittypes = Unittype.order('unit_type_priority ASC')
    # @sections = Section.find(:all, :conditions => ["unit_id =?",current_user.unit_id]) rails 4 comment
    @sections = Section.where(:unit_id => current_user.unit_id)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @units.to_json(:include => [:unit_detail, :children, {:sections => {:include => :menu_cards}}] ) }
    end
  end

  # GET /units/1
  # GET /units/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/units/:id', "Detailed description of a branch with its users, menu cards, sections, tables."
  error :code => 401, :desc => "Unauthorized"
  param :id, :number, :desc => "Unit ID", :required => true
  #param :session, String, :desc => "user is logged in", :required => true
  description "URL : http://lazeez.stewot.com/units/10.json?device_id=YOTTO05"
  formats ['json', 'jsonp']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def show
    @unit = Unit.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unit.to_json(:include =>
          [:unit_detail,
            {:advertisements => {:include => {:advertisement_galleries =>{:only => [:advertisement_image_url], :methods => [:advertisement_image_url]}}}},
            {:users => {:include => :profile}},
            :unittype,
            {:sections => {:include => [:menu_cards, :tables]}},
            {:printers => {:include => {:assignable => {:only => [:name]}}}}
          ] ) }
    end
  end

  # GET /units/new
  # GET /units/new.json
  def new
    @unit = Unit.new
    @parent_unit = Unit.find(params[:unit_parent])
    puts @parent_unit.inspect
    #@unittypes = Unittype.order('unit_type_priority ASC')
    @unittypes = Unittype.by_same_and_less_position(@parent_unit.unittype.position).order('position ASC')
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
    @parent_unit = Unit.find(@unit.unit_parent || @unit)
    @unittypes = Unittype.by_same_and_less_position(@parent_unit.unittype.position).order('position ASC')
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(params[:unit])
    puts "unit_parent:#{@unit.unit_parent}"
    @parent_unit = Unit.find(@unit.unit_parent)
    @unittypes = Unittype.by_less_position(@parent_unit.unittype.position).order('position ASC')
    respond_to do |format|
      if @unit.save
        if params[:is_account_creation].present? and params[:is_account_creation] == 'true'
          @unit_account = FinancialAccount.new
          @unit_account.account_holder_id = @unit.id
          @unit_account.account_holder_type = "Unit"
          @unit_account.account_type = "seller"
          @unit_account.save
        end
        format.html { redirect_to units_path, notice: I18n.t('unit.create.notice') }
        format.js
      else
        format.html { render action: "new"}
        format.js
      end
    end
  end

  # PUT /units/1
  # PUT /units/1.json
  def update
    @unit = Unit.find(params[:id])
    @parent_unit = Unit.find(@unit.unit_parent || @unit)
    @unittypes = Unittype.by_less_position(@parent_unit.unittype.position).order('position ASC')
    respond_to do |format|
      if @unit.update_attributes(params[:unit])
        if params[:is_account_creation].present? and params[:is_account_creation] == 'true'
          unless @unit.financial_account.present?
            @unit_account = FinancialAccount.new
            @unit_account.account_holder_id = @unit.id
            @unit_account.account_holder_type = "Unit"
            @unit_account.account_type = "seller"
            @unit_account.save
          end
        else
          if @unit.financial_account.present?
            @unit.financial_account.destroy
          end
        end
        format.html { redirect_to @unit, notice: I18n.t('unit.update.notice') }
        format.js
      else
        format.html { render action: "edit" }
        format.js
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit = Unit.find(params[:id])
    begin
      @unit.destroy
      respond_to do |format|
        format.html { redirect_to units_url, notice: I18n.t('unit.destroy.notice')  }
        format.js
      end
      # rescue Exception => @error
      # respond_to do |format|
      #   format.html { redirect_to units_url, alert: @error.message  }
      #   format.js
      # end
    end
  end

  def thirdparty_upload
    @thirdparty_configuration = ThirdpartyConfiguration.find(params[:upload_thitdparty_id])
    if @thirdparty_configuration.present? && @thirdparty_configuration.thirdparty =="urban_piper"
      @unit_hash={}
      @unit_hash["stores"]=[]
      JSON.parse(params[:unit_id]).each do |ui|
        @unit=Unit.find(ui)
        # @unit=Unit.find(params[:unit_id])
        _role_owner = Role.find_by_name('owner')
        _role_outlet_manager = Role.find_by_name('outlet_manager')
        _role_bill_manager = Role.find_by_name('owner')
        @owner = _role_owner.present? ? User.by_unit(ui).by_role(_role_owner.id) : []
        @outlet_manager = _role_outlet_manager.present? ? User.by_unit(ui).by_role(_role_outlet_manager.id) : []
        @bill_manager = _role_bill_manager.present? ? User.by_unit(ui).by_role(_role_bill_manager.id) : []
        @unit_dtls={}
        @unit_dtls["city"]=@unit.city.present? ? @unit.city : nil
        @unit_dtls["name"]=@unit.unit_name.present? ? @unit.unit_name : nil
        @unit_dtls["min_pickup_time"]=900
        @unit_dtls["min_delivery_time"]=1800
        @unit_dtls["contact_phone"]=@unit.phone.present? ? @unit.phone : '+91'
        @unit_dtls["notification_phones"]=[]
        @unit_dtls["notification_emails"]=[]
        @owner.each do |o|
          o.profile.contact_no.present? ? @unit_dtls["notification_phones"].push(o.profile.contact_no) : ""
          o.email.present? ? @unit_dtls["notification_emails"].push(o.email) : ""
        end
        @outlet_manager.each do |om|
          om.profile.contact_no.present? ? @unit_dtls["notification_phones"].push(om.profile.contact_no) : ""
          om.email.present? ? @unit_dtls["notification_emails"].push(om.email) : ""
        end
        @bill_manager.each do |bm|
          bm.profile.contact_no.present? ? @unit_dtls["notification_phones"].push(bm.profile.contact_no) : ""
          bm.email.present? ? @unit_dtls["notification_emails"].push(bm.email) : ""
        end
        @unit_dtls["ref_id"]=@unit.id
        @unit_dtls["min_order_value"]=200
        @unit_dtls["hide_from_ui"]=false
        @unit_dtls["address"]=@unit.address.present? ? @unit.address : nil
        @unit_dtls["zip_codes"]=[]
        @unit.pincode.present? ? @unit_dtls["zip_codes"].push(@unit.pincode) : ""
        @unit_dtls["geo_longitude"]=@unit.longitude.present? ? @unit.longitude : nil
        @unit_dtls["active"]=true
        @unit_dtls["geo_latitude"]=@unit.latitude.present? ? @unit.latitude : nil
        @unit_dtls["ordering_enabled"]=true
        @unit_hash["stores"].push(@unit_dtls)
      end
      @unit_uploaded = ThirdpartyUrbanpiper.thirdparty_urbanpiper_unit_upload(@thirdparty_configuration, @unit_hash.to_json)
      if @unit_uploaded==true
        redirect_to :back, notice: 'Unit was successfully uploaded to urbanpiper.'      
      else
        redirect_to :back, alert: 'Failed to upload unit to urbanpiper.'
      end
    else
      redirect_to :back, alert: 'Failed to upload unit to urbanpiper, thirdparty_name missing.'  
    end
  end

  def urbanpiper_toggle
    if params[:thirdparty_toggle_section_id].present?
      @thirdparty_configuration = ThirdpartyConfiguration.find_by_section_id_and_thirdparty(params[:thirdparty_toggle_section_id],"urban_piper")
      @toggle_hash = {}
      if JSON.parse(params[:toggle_unit_id]).count > 0
        if @thirdparty_configuration.present?
          @unit_toggled = []
          JSON.parse(params[:toggle_unit_id]).each do |ui|
            if params[:urbanpiper_ch].present?
              @toggle_hash["location_ref_id"] = ui
              @toggle_hash["platforms"]= params[:urbanpiper_ch]
              @toggle_hash["action"]=params[:urbanpiper_channel_isactive].present? ? "enable" : "disable"
            end
            _result = {}
            _result[:unit_id] = ui
            _result[:result] = ThirdpartyUrbanpiper.thirdparty_urbanpiper_unit_channel_toggle(@thirdparty_configuration, @toggle_hash.to_json)
            @unit_toggled.push(_result)
          end
          if @unit_toggled.count > 0
            _toggled = []
            _untoggled = []
            @unit_toggled.each do |r|
              if r[:result] == true
                _toggled.push(r[:unit_id])
              else
                _untoggled.push(r[:unit_id])
              end
            end
            _message = _toggled.count > 0 ? "Units with IDs #{_toggled.join(', ')} are successfully toggled to urbanpiper." : ""
            _message = _toggled.count > 0 && _untoggled.count > 0 ? "#{_message} AND " : "#{_message}"
            _message = _untoggled.count > 0 ? "Units with IDs #{_untoggled.join(', ')} are failed to urbanpiper toggle." : "#{_message}"
            redirect_to :back, notice: "#{_message}"
          else
            redirect_to :back, alert: "Urbanpiper toggle failed."
          end
        else
          redirect_to :back, alert: 'Urban piper API not present in the selected section.'
        end 
      else
        redirect_to :back, alert: 'Select atlist one outlet.'
      end
    else
      redirect_to :back, alert: 'Select a section...'
    end       
  end

  def fetch_unit_details
    @address = params[:address]
    @unit_info = Geocoder.search(@address)
    @all_outlet = {}
    @sublocality = Array.new
    @routes = Array.new
    @street_number = Array.new
    if @unit_info
        @unit_info.each do |ui|
          @addrs_comp = ui.address_components
          @addrs_comp.each do |ac|
            if ac["types"].include? "country"
              country = ac["long_name"]
              @all_outlet[:country] = country
            end
            if ac["types"].include? "administrative_area_level_1"
              state = ac["long_name"]
              @all_outlet[:state] = state
            end
            if ac["types"].include? "administrative_area_level_2"
              city = ac["long_name"]
              @all_outlet[:district] = city
            end
            if ac["types"].include? "locality"
              locality = ac["long_name"]
              @all_outlet[:city] = locality
            end
            if ac["types"].include? "sublocality"
              @sublocality.push ac["long_name"]
            end
            if ac["types"].include? "route"
              @routes.push ac["long_name"]
            end
            if ac["types"].include? "street_number"
              @street_number.push ac["long_name"]
            end
            if ac["types"].include? "postal_code"
              @all_outlet[:pincode] = ac["long_name"]
            end
          end
          @all_outlet[:locality] = @sublocality
          @all_outlet[:route] = @routes
          @all_outlet[:street_number] = @street_number
        end
      end
    respond_to do |format|
      format.json { render json: @all_outlet }
    end
  end

  def fetch_units
    menu_product = params[:menu_product]
    source = params[:source]
    #################### to get all leaf unit details by location #############################
    max_unittype_pri = Unittype.order('unit_type_priority DESC').first
    leaf_unittype_id = max_unittype_pri.id
    if(params[:location])
      if(params[:location] != "")
        city = params[:location]
        unitall = Unit.where(:unittype_id => leaf_unittype_id, :city => city)
      else
        unitall = Unit.where(:unittype_id => leaf_unittype_id)
      end
    else
      unitall = Unit.where(:unittype_id => leaf_unittype_id)
    end

    #################### to get info window in gmap for units #############################
    @hash = BranchManagement::get_infowindow(unitall, menu_product, source)


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hash}
    end
  end

  #fetch unit parent dropdown while creating a unit depending on the value of the unit type that we will create
  def fetch_drop
    @id = params[:id]
    @unit_info = BranchManagement::branchs_get_parent_units(@id)# get units of parrent_unittype
    respond_to do |format|
      format.json { render :json => @unit_info.to_json(:include => :unittype)}
      end
    end

  # to fetch all unit information of a selected storage unit type (etc brand/branch)
  def fetch_unit_type
    @id = params[:id]
    @unit_type_info = Unit.where(:unittype_id => @id)

    respond_to do |format|
      format.json { render :json => @unit_type_info}
    end
  end

  def fetch_sections
    @id = params[:unit_id]
    @unit_sections = Unit.find(@id).sections

    respond_to do |format|
      format.json { render :json => @unit_sections}
    end
  end

  def fetch_thirdparties
    @id = params[:section_id]
    @thirdparties = Section.find(@id).thirdparty_configurations

    respond_to do |format|
      format.json { render :json => @thirdparties}
    end
  end

  def get_tax_group
    _unit = Unit.find(params[:id])

    respond_to do |format|
      format.json { render :json => _unit.to_json(:include => {:sections => {:include => :tax_groups}})}
    end
  end

  private

  def set_module_details
    @module_id = "units"
    @module_title = "Organization"
  end
end
