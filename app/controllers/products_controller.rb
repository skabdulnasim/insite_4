class ProductsController < ApplicationController
  load_and_authorize_resource :except => [:add_retail_items_to_catalog]
  require 'json'

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  layout "material"
  # layout :resolve_layout

  before_filter :set_module_details
  before_filter :get_product_generic_smartlists, only: [:index, :new, :edit, :create, :update]

  # GET /products
  # GET /products.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/products.json', "Get all products"
  error :code => 401, :desc => "Unauthorized"
  description "Get all products of all outlets"
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def index
    @categories = Category.all
    @all_products = Product.get_all
    @attribute_sets = ProductAttributeSet.all
    smart_listing_create :products, @product_scope, partial: "products/products_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
      format.json { render json: @product_scope}
    end
  end

  # GET /products/1
  # GET /products/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/products/:id', "Show product description"
  error :code => 401, :desc => "Unauthorized"
  param :id, :number, :desc => "Product ID", :reqired => true
  description "Detailed description of a product"
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def show
    # @p_meta = {}
    @product = Product.find(params[:id])
    @products = Product.get_all
    @related_products = Product.get_related_product(@product)
    @product_raw_meta = Product.get_product_meta(@product[:id], "raw")
    if @product.sku.present?
      require 'barby'
      require 'barby/barcode/code_128'
      require 'barby/outputter/png_outputter'
      #Barcode generation
      @ean_barcode = Barby::Code128B.new(@product.sku)
      @png_blob = Barby::PngOutputter.new(@ean_barcode).to_png(:margin => 2, :xdim => 3, :height => 65)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product.to_json(:include =>:product_attrs) }
      format.png do
        send_data @png_blob, type: "image/png", disposition: "inline"
      end
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new(product_attribute_set_id: params[:product_attribute_set_id], business_type: params[:business_type], product_type: params[:product_type])
    @basic_units = ProductBasicUnit.all
    @conjugated_units =ConjugatedUnit.all
    @product_religions = ProductReligion.all
    @product_allergies = Allergy.all
    @production_processes = ProductionProcess.order("id asc")
    @colors = Color.order("id asc")
    @colors = @colors.filter_by_name(params[:color_filter]) if params[:color_filter].present?
    @sizes = Size.order("id asc")
    @sizes = @sizes.filter_by_name(params[:size_filter]) if params[:size_filter].present?
    @attributes = Attribute.all
    @inventory_status = AppConfiguration.get_config_value('inventory_module')
    @tags = Tag.active
    if current_user.role.name == 'owner'
      @vendors = Vendor.order("id asc")
      @menu_cards = MenuCard.order("id asc")
    elsif current_user.role.name == 'dc_manager'
      unit_ids = []
      @current_user.unit.children.map { |e| unit_ids.push e.id } if @current_user.unit.children.present?
      unit_ids << @current_user.unit.id
      @vendors = Vendor.set_unit_id_in(unit_ids)
      @menu_cards = MenuCard.by_unit_in(unit_ids)
    else
      @vendors = current_user.unit.vendors
      @menu_cards = current_user.unit.menu_cards
    end
    @vendors = @vendors.vendor_like(params[:vendor_filter]) if params[:vendor_filter].present?
    # @variable_products = Product.find(:all, :select => 'id, name', :conditions => { product_type: "variable" })
    @variable_products = Product.where(:product_type => "variable").select("id, name")
    smart_listing_create :compositions, @product_scope, partial: "products/products_raw_smartlist", default_sort: {id: "desc"}
    smart_listing_create :process_compositions, @production_processes, partial: "products/production_processes_smartlist", default_sort: {id: "desc"}
    smart_listing_create :colors, @colors, partial: "products/colors_smartlist", default_sort: {id: "desc"}
    smart_listing_create :sizes, @sizes, partial: "products/sizes_smartlist", default_sort: {id: "desc"}
    smart_listing_create :vendors, @vendors, partial: "products/vendors_smartlist", default_sort: {id: "desc"}
    smart_listing_create :menu_cards, @menu_cards, partial: "products/menu_cards_smartlist", default_sort: {id: "desc"}
    smart_listing_create :tags, @tags, partial: "products/tag_smartlist",default_sort: {id: "desc"}
    respond_to do |format|
      format.js
      format.html # new.html.erb
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
    @basic_units = ProductBasicUnit.all
    @conjugated_units =ConjugatedUnit.all
    @product_religions = ProductReligion.all
    @product_allergies = Allergy.all
    _product_colors = ColorProduct.by_product_id(params[:id]).pluck(:color_id)
    @colors = Color.order("id asc")
    @colors = @colors.color_not_in(_product_colors) if _product_colors.present?
    @colors = @colors.filter_by_name(params[:color_filter]) if params[:color_filter].present?
    @color_products = @product.color_products
    @product_sizes = @product.product_sizes
    @production_processes = ProductionProcess.order("id asc")
    @attributes = Attribute.all
    _product_size = ProductSize.by_product_id(params[:id]).pluck(:size_id)
    @sizes = Size.order("id asc")
    @sizes = @sizes.size_not_in(_product_size) if _product_size.present?
    @sizes = @sizes.filter_by_name(params[:size_filter]) if params[:size_filter].present?
    # @vendors = Vendor.order("id asc")
    @inventory_status = AppConfiguration.get_config_value('inventory_module')
    if current_user.role.name == 'owner'
      @vendors = Vendor.order("id asc")
      @menu_cards = MenuCard.order("id asc")
      @menu_products = @product.menu_products
    elsif current_user.role.name == 'dc_manager'
      unit_ids = []
      @current_user.unit.children.map { |e| unit_ids.push e.id } if @current_user.unit.children.present?
      unit_ids << @current_user.unit.id
      @vendors = Vendor.set_unit_id_in(unit_ids)
      @menu_cards = MenuCard.by_unit_in(unit_ids)
      _menu_card_ids = @menu_cards.pluck(:id)
      @menu_products = @product.menu_products.set_menu_card_in(_menu_card_ids)
    else
      @vendors = current_user.unit.vendors
      @menu_cards = current_user.unit.menu_cards
      _menu_card_ids = @menu_cards.pluck(:id)
      @menu_products = @product.menu_products.set_menu_card_in(_menu_card_ids)
    end
    @tags = Tag.active
    @product_tags = @product.product_tags
    @vendors = @vendors.vendor_like(params[:vendor_filter]) if params[:vendor_filter].present?
    _vendor_ids = @vendors.pluck(:id)
    @vendor_products = @product.vendor_products.set_vendor_id_in(_vendor_ids)
    @variable_products = Product.where(:product_type => "variable").select("id, name")
    @attributes_details = ProductManagement::get_product_meta(params[:id], "attributes")
    if !@attributes_details.nil?
      @attribute_arr = Array.new
      @attributes_details.each do |ad|
        # attribute_par = TermAttribute.find(:first, :select => 'attribute_id', :conditions => ["id =?", ad])
        attribute_par = TermAttribute.where(:id => ad).first.select('attribute_id')
        @attribute_arr.push attribute_par[:attribute_id]
      end
      @attribute_arr = @attribute_arr.uniq
    end
    smart_listing_create :compositions, @product_scope, partial: "products/products_raw_smartlist", default_sort: {id: "desc"}
    smart_listing_create :process_compositions, @production_processes, partial: "products/production_processes_smartlist", default_sort: {id: "desc"}
    smart_listing_create :colors, @colors, partial: "products/colors_smartlist", default_sort: {id: "desc"}
    smart_listing_create :color_products, @color_products, partial: "products/color_product_smartlist", default_sort: {id: "desc"}
    smart_listing_create :product_sizes, @product_sizes, partial: "products/product_sizes_smartlisting", default_sort: {id: "desc"}
    smart_listing_create :sizes, @sizes, partial: "products/sizes_smartlist", default_sort: {id: "desc"}
    smart_listing_create :vendors, @vendors, partial: "products/vendors_smartlist", default_sort: {id: "desc"}
    smart_listing_create :menu_cards, @menu_cards, partial: "products/menu_cards_smartlist", default_sort: {id: "desc"}
    smart_listing_create :tags, @tags, partial: "products/tag_smartlist",default_sort: {id: "desc"}
    respond_to do |format|
      format.html #
      format.js
    end
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(params[:product])
    @basic_units = ProductBasicUnit.all
    @conjugated_units =ConjugatedUnit.all
    @product_allergies = Allergy.all
    @production_processes = ProductionProcess.order("id asc")
    smart_listing_create :compositions, @product_scope, partial: "products/products_raw_smartlist", default_sort: {id: "desc"}
    smart_listing_create :process_compositions, @production_processes, partial: "products/production_processes_smartlist", default_sort: {id: "desc"}
    respond_to do |format|
      if @product.save
        AllergyProduct.save_product_to_allergy_product(@product.id, params['allergie_id']) if params[:allergie_id].present?
        ###############  The new way to save attributes with its terms ##########################################
        if params['attribute'].present?
          ProductAttribute.save_product_attributes(@product,params['attribute'],params[:variant])
        end

        # Saving product input and output unit
        params[:input_units].map{|unit_id|  ProductTransactionUnit.create_for @product, 'input', unit_id ,params["input_multiplier_#{unit_id}"] } if params[:input_units].present?
        params[:output_units].map{|unit_id| ProductTransactionUnit.create_for @product, 'output', unit_id,params["output_multiplier_#{unit_id}"] } if params[:output_units].present?

        if params[:term_attribute]
          _product_metum_attributes = ProductMetum.new(params[:product_metum])
          ####Create product attributes(for variants product)
          ProductMetum.save_product_metum_attributes(@product,_product_metum_attributes,params[:term_attribute])
        end

        if params[:variant]
          _product_metum_variants = ProductMetum.new(params[:product_metum])
          ProductMetum.save_product_metum_variants(@product,_product_metum_variants,params[:variant])
        end

        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])
    AllergyProduct.save_product_to_allergy_product(@product.id, params['allergie_id']) if params[:allergie_id].present?
    respond_to do |format|
      if @product.update_attributes(params[:product])
        # Saving product input and output unit

        input_transaction_units = @product.input_units.pluck(:product_unit_id)
        output_transaction_units = @product.output_units.pluck(:product_unit_id)
        
        input_transaction_status_changable = params[:input_units].present? ? input_transaction_units - params[:input_units].map{|uid|uid.to_i} : input_transaction_units
        output_transaction_status_changable = params[:output_units].present? ? output_transaction_units - params[:output_units].map{|uid|uid.to_i} : output_transaction_units 
        
        change_transaction_status("input",input_transaction_status_changable,@product)
        change_transaction_status("output",output_transaction_status_changable,@product)
        #new process to update product transaction unit
        if params[:input_units].present?
          transaction_type = "input"
          params[:input_units].each do |input_unit|
            unit_multiplier = params["input_multiplier_#{input_unit}"]
            proceed_for_update_transaction_unit(@product,transaction_type,input_unit,unit_multiplier)
          end
        end
        if params[:output_units].present?
          transaction_type = "output"
          params[:output_units].each do |output_unit|
            unit_multiplier = params["output_multiplier_#{output_unit}"]
            proceed_for_update_transaction_unit(@product,transaction_type,output_unit,unit_multiplier)
          end
        end
        # old process for updating product transaction unit
        # ProductTransactionUnit.delete_all("product_id = #{@product.id}")
        # params[:input_units].map{|unit_id| ProductTransactionUnit.create_for @product, 'input', unit_id ,params["input_multiplier_#{unit_id}"]} if params[:input_units].present?
        # params[:output_units].map{|unit_id| ProductTransactionUnit.create_for @product, 'output', unit_id, params["output_multiplier_#{unit_id}"]} if params[:output_units].present?

        if params[:term_attribute]
          _product_metum_attributes = ProductMetum.where(:product_id => params[:id], :meta_key =>"attributes").last
          ####Update product attributes(for variants product)
          ProductMetum.save_product_metum_attributes(@product,_product_metum_attributes,params[:term_attribute])
        end

        #################################  The new way to update attributes with its terms ##########################################
        if params['attribute'].present?
          ProductAttribute.delete_all("product_id = #{@product.id}")
          ProductAttribute.save_product_attributes(@product,params['attribute'],params[:variant])
        end

        if params[:variant]
          puts "Varient : #{params[:variant]}"
          _product_metum_variants = ProductMetum.where(:product_id => @product.id, :meta_key =>"variants").last
          _product_metum_variants = ProductMetum.new(params[:product_metum]) unless _product_metum_variants.present?
          ProductMetum.save_product_metum_variants(@product,_product_metum_variants,params[:variant])
        end

        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def search_products
    render json: Product.product_for(params[:term])
  end

  def new_import
  end

  def new_size_image_import
  end

  def size_image_import
    begin
      ActiveRecord::Base.transaction do
        ProductSize.import_product_size_image(params[:file])
        redirect_to products_path, notice: 'Products size images was successfully imported.'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to new_size_image_import_products_path
    end
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        Product.import(params[:file])
        redirect_to products_path, notice: 'Products was successfully imported.'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to new_import_products_path
    end
  end

  def toggle_trash
    @product = Product.find(params[:id])
    _status = @product.is_trashed == false ? true : false
    @product.update_attributes(:is_trashed => _status)
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully updated.' }
      format.json { head :no_content }
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def settings
    @physical_type = PhysicalType.new(params[:physical_type])
    if params[:id]
      @physical_type = PhysicalType.find(params[:id])
    end
    @physical_types = PhysicalType.all
    @physical_types_pagination = PhysicalType.page(params[:page])

    @product_unit = ProductUnit.new
    @product_units = ProductUnit.all
    @product_unit_pagination = ProductUnit.page(params[:page])

    @tax_class= TaxClass.new
    @tax_classes = TaxClass.all
    @tax_class_pagination = TaxClass.page(params[:page])
    @product_basic_unit= ProductBasicUnit.all
  end

  def product_edit
    @edit_product = PhysicalType.find(params[:id])
    respond_to do |format|
      format.json { render :json => @edit_product }
    end
  end

  def product_edit_unit
    @edit_product_unit = ProductUnit.find(params[:id])

    respond_to do |format|
      format.json { render :json => @edit_product_unit }
    end
  end

  def product_update
    respond_to do |format|
      if PhysicalType.where(:id => params[:id]).update_all(:name => params[:physicalname])
        format.html { redirect_to products_settings_path, notice: 'successfully Updated.' }
      end
    end
  end

  def product_unit_update
    respond_to do |format|
      if ProductUnit.where(:id => params[:id]).update_all(:name => params[:name], :multiplier => params[:multiplier], :basic_inventory_unit=> params[:basic_inventory_unit])
        format.html { redirect_to products_settings_path, notice: 'ProductUnit successfully Updated.' }
      end
    end
  end

  def product_edit_tax
    @edit_product_tax = TaxClass.find(params[:id])
    respond_to do |format|
      format.json { render :json => @edit_product_tax }
    end
  end

  def product_tax_update
    respond_to do |format|
      if TaxClass.where(:id => params[:id]).update_all(:name => params[:name], :tax_type=> params[:tax_type], :ammount=> params[:ammount])
        format.html { redirect_to products_settings_path, notice: 'ProductTax successfully Updated.' }
      end
    end
  end

  def product_color_update
    @color_product = ColorProduct.find_by_product_id_and_color_id(params[:product_id],params[:color_id])
    @color_product.update_attributes(:status=>params[:config_value])
    respond_to do |format|
      format.json { render :json => @color_product }
    end
  end

  def product_size_update
    @product_size = ProductSize.find_by_product_id_and_size_id(params[:product_id],params[:size_id])
    @product_size.update_attributes(:status=>params[:config_value])
    respond_to do |format|
      format.json { render :json => @product_size }
    end
  end

  def add_tax
    @simple_tax_classes = TaxClass.where(:tax_type => "simple")

    respond_to do |format|
      format.json { render :json => @simple_tax_classes }
    end
  end

  def get_all_attributes
    id = params[:id]
    attributes_details = ProductManagement::get_product_meta(id, "attributes")
    #ll = attributes_details.include?("2")
    final_arrs = Array.new
    attributes = Attribute.all
    attributes.each do |attribute|
      one_arr = {}
      term_arr = {}
      terms_arr = Array.new
      terms = TermAttribute.where(:attribute_id => attribute[:id])
      terms.each do |term|
        id = "#{term[:id]}"
        if attributes_details.include?id

          term_arr[:name] = term[:name]
          term_arr[:id] = "#{term[:id]}"
          terms_arr.push term_arr



          one_arr[:attribute_id]=attribute[:id]
          one_arr[:attribute_name]=attribute[:name]
          one_arr[:terms]=terms_arr

        end
        term_arr = {}
      end
      final_arrs.push one_arr
      final_arrs.reject! { |c| c.empty? }
    end
    respond_to do |format|
      format.json { render :json => final_arrs }
    end
  end

  def bulk_upload
    ActiveRecord::Base.transaction do
      uploaded_file = params[:csv_file]
      file_name = uploaded_file.tempfile.to_path.to_s
      uploaded_file_type = uploaded_file.original_filename.split('.')

      raise "The format should be in csv" unless uploaded_file_type[1] == "csv"
      SmarterCSV.process(file_name) do |header|
        Product.product_csv_upload(header)
      end
      respond_to do |format|
        format.html { redirect_to products_path, notice: "Products were uploaded successfully." }
      end
    end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.html { redirect_to products_path, alert: e.message.to_s }
      end
  end

  def unit_products
    @categories = Category.all
    @product_scope = current_user.unit.products
    @product_scope = @product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    @product_scope = @product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    @product_scope = @product_scope.set_category(params[:category_id]) if params[:category_id].present?
    @product_scope = @product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, @product_scope, partial: "products/branch_products_smartlist", default_sort: {id: "desc"}
  end

  def add_products
    @categories = Category.all
    @tax_groups = TaxGroup.all
    _unit_products = current_user.unit.unit_products.pluck(:product_id)
    @product_scope = Product.get_all
    @product_scope = @product_scope.product_not_in(_unit_products) if _unit_products.present?
    @product_scope = @product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    @product_scope = @product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    @product_scope = @product_scope.set_category(params[:category_id]) if params[:category_id].present?
    @product_scope = @product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, @product_scope, partial: "products/unit_products_smartlist", default_sort: {id: "desc"}
  end

  def save_products
    begin
      raise 'No Product checkbox selected.' unless params[:products].present?
      ActiveRecord::Base.transaction do # Protective transaction block
        params[:products].each do |pro|
          _menu_product = current_user.unit.unit_products.create(:product_id=>pro,:input_tax_group_id=>params[:tax_group_id])
        end
      end
      redirect_to unit_products_products_path, notice: "Products successfully added to your branch"
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to unit_products_products_path, alert: e.message.to_s
    end
  end
  def edit_unit_products
    @unit_product = UnitProduct.find_by_unit_id_and_product_id(current_user.unit_id,params[:id])
    # @tax_groups = TaxGroup.by_section_ids(current_user.unit.sections.pluck(:id))
    @tax_groups = TaxGroup.all
  end
  def update_unit_products
    begin
      unit_product = UnitProduct.find_by_unit_id_and_product_id(current_user.unit_id,params[:id])
      unit_product.update_attribute(:input_tax_group_id,params[:tax_group_id])
      redirect_to unit_products_products_path, notice:"product successfully updated"
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to unit_products_products_path , alert:e.message.to_s
    end
  end
  def remove_unit_product
    _product = current_user.unit.unit_products.by_product(params[:id]).first
    _product.destroy
    respond_to do |format|
      format.html { redirect_to unit_products_products_path, notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def process_dependency
    @product_id = params[:id]
    @product_name = Product.find(@product_id).name
    @process_composition_list = ProcessComposition.by_product_id(@product_id)
  end

  def add_process_dependency
    begin
      raise 'No process checkbox selected' unless params[:selected_processes].present?
      ActiveRecord::Base.transaction do
        prev = DependsOnProcess.where('process_composition_id =?', params[:process_composition_id])
        prev.destroy_all if prev.present?
        params[:selected_processes].each do |selected_process|
          _depend_on_process = DependsOnProcess.create(:process_composition_id=>params[:process_composition_id],:process_id=>selected_process)
        end
      end  
      redirect_to process_dependency_product_path(params[:product_id]), notice: "Process dependency successfully added to process" 
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to process_dependency_product_path(params[:product_id]), alert: e.message.to_s      
    end
  end

  def delete_composition
    main_product_id = params[:main_product_id]
    raw_product_id = params[:raw_product_id]
    @composition = ProductComposition.find_by_product_id_and_raw_product_id(main_product_id,raw_product_id)
    if @composition.present?
      @composition.destroy
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def delete_vendor_product
    vendor_product_id = params[:vendor_product_id]
    @vendor_product = VendorProduct.find(vendor_product_id)
    if @vendor_product.present?
      @vendor_product.destroy
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def delete_product_tag
    product_tag_id = params[:product_tag_id]
    @product_tag = ProductTag.find(product_tag_id)
    if @product_tag.present?
      @product_tag.destroy
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def delete_product_image
    product_image_id = params[:product_image_id]
    @product_image = ProductImage.find(product_image_id)
    if @product_image.present?
      @product_image.destroy
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def delete_product_size_image
    product_size_image_id = params[:product_size_image_id]
    @product_size_image = ProductSizeImage.find(product_size_image_id)
    if @product_size_image.present?
      @product_size_image.destroy
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def delete_menu_product
    menu_product_id = params[:menu_product_id]
    @menu_product = MenuProduct.find(menu_product_id)
    if @menu_product.present?
      @menu_product.destroy
    end
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def proceed_for_update_transaction_unit(product,transaction_type,unit_id,unit_multiplier)
    transaction_unit = ProductTransactionUnit.where("product_id=? AND transaction_type=? AND product_unit_id=?",product.id,transaction_type,unit_id).first
    if transaction_unit.present?
      ProductTransactionUnit.update_for transaction_unit,unit_multiplier
    else
      ProductTransactionUnit.create_for @product,transaction_type , unit_id ,unit_multiplier
    end
  end
  
  def change_transaction_status(transaction_type,status_changable_unit_list,product_obj)
    if transaction_type == "input"
      transactions = product_obj.input_units.by_unit_id_list(status_changable_unit_list)   
    else
      transactions = product_obj.output_units.by_unit_id_list(status_changable_unit_list)
    end
    transactions.update_all(status: false)
  end

  def set_module_details
    @module_id = "products"
    @module_title = "Products"
  end

  def get_product_generic_smartlists
    @product_units = ProductUnit.order("id")
    @product_scope = Product.get_all
    @product_scope = @product_scope.filter_by_product_type(params[:product_type]) if params[:product_type].present?
    @product_scope = @product_scope.filter_by_product_category(params[:product_category]) if params[:product_category].present?
    @product_scope = @product_scope.set_category(params[:category_id]) if params[:category_id].present?
    @product_scope = @product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    @product_scope = @product_scope.filter_by_item_code(params[:itemcode]) if params[:itemcode].present?
    @product_scope = @product_scope.filter_by_brand_name(params[:brandname]) if params[:brandname].present?
    @product_scope = @product_scope.filter_by_mfr_name(params[:mfrname]) if params[:mfrname].present?
    @product_scope = @product_scope.filter_by_itemcode_brand_mfr(params[:itemcode_brand_mfr]) if params[:itemcode_brand_mfr].present?
    @product_scope = @product_scope.filter_by_product_id(params[:product_id_filter]) if params[:product_id_filter].present?
  end
end
