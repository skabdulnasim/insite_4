include MenuCardsHelper
class MenuCardsController < ApplicationController
  load_and_authorize_resource :except => [ :mode_toggle ]

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  layout "material"

  before_filter :set_module_details

  respond_to :json

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  menu_card_index_api
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  # GET /menu_cards
  # GET /menu_cards.json
  def index
    _current_unit = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @all_units_types = Unittype.all
    # @menu_product = MenuProduct.new
    menu_scope = MenuCard.set_unit(_current_unit).not_trashed
    menu_scope = menu_scope.set_scope(params[:scope]) if params[:scope].present?
    menu_scope = menu_scope.set_mode(params[:mode]) if params[:mode].present?
    @new_menu_scope = MenuCard.set_unit(_current_unit).not_trashed
    @new_menu_scope = menu_scope.set_scope(params[:scope]) if params[:scope].present?
    @new_menu_scope = menu_scope.set_mode(params[:mode]) if params[:mode].present?
    smart_listing_create :menu_cards, menu_scope, partial: "menu_cards/menu_smartlist",default_sort: {created_at: "desc"}

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: menu_scope.active.to_json(:include =>
        [{:menu_categories_variable_nil => {:include => :submenucategories}}, {:menu_products_variable_nil => {:include =>
          [{:variants =>{:include =>
            [{:product => {:include => [:product_meta, {:product_attrs => {:include => :term_attributes}}]} }, :menu_category,
              {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types]}},

            {:product => {:include => [:product_meta, {:product_attrs => {:include => :term_attributes}}]} }, :menu_category,
              {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types]} }]) }
    end
  end

  def show
    @menu_card = MenuCard.find(params[:id])
    @menu_categories = @menu_card.menu_categories
    @menu_cards = MenuCard.set_unit(current_user.unit_id) if current_user.present?
    @alpha_promotion_codes = Unit.find(@menu_card.unit_id).alpha_promotions.active.staff_promo
    # @menu_card_products = @menu_card.menu_products.by_menu_card(@menu_card.id).order("menu_category_id asc")
    @menu_card_products = @menu_card.menu_products.order("menu_category_id asc")
    @menu_card_products = @menu_card_products.filter_by_string(params[:filter]) if params[:filter].present?
    @menu_card_products = @menu_card_products.filter_by_menu_category(params[:menu_category]) if params[:menu_category].present?
    @menu_card_products = @menu_card_products.filter_by_sku(@menu_card_products,params[:sku_filter]) if params[:sku_filter].present?
    @bill_destinations = Unit.find(@menu_card.unit_id).bill_destinations
    smart_listing_create :menu_card_products, @menu_card_products, partial: "menu_cards/menu_card_product_smartlist", default_sort: {created_at: "desc"}
    @sale_rules = SaleRule.active.valid_till
    @tags = Tag.all

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @menu_card.to_json(:include =>
        [{:menu_categories_variable_nil => {:include => :submenucategories}},
         {:menu_products_variable_nil => {:include =>
          [ {:tax_group => {:include => :tax_classes}}, {:variants =>{:include =>
              [{:product => {:include => [:product_meta, {:product_attrs => {:include => :term_attributes}}]} },
                {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types]}},

            {:combos =>{:include =>
            [{:product => {:include => [:product_meta, {:product_attrs => {:include => :term_attributes}}]} }, :menu_category,
              {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types]}},

            {:product => {:include => [:product_meta, {:product_attrs => {:include => :term_attributes}}]} },
              {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types
          ]} }
        ])}
    end
  end

  def mode_toggle
    @menu_card = MenuCard.find(params[:id])
    @active_cards = MenuCard.set_scope(@menu_card.scope).set_mode(1).set_section(@menu_card.section_id).not_trashed.set_operation_type(@menu_card.operation_type) if params[:mode] == "1"
    @menu_card.update_attribute(:mode,params[:mode]) unless @active_cards.present?
    respond_to do |format|
      format.json { render :json => @menu_card}
    end
  end

  # GET /menu_cards/new
  # GET /menu_cards/new.json
  def new
    @menu_card = MenuCard.new
    @current_user_id = get_current_user_id()
    @current_user_info = UserManagement::get_current_user(@current_user_id)
    @sections = Section.where(:unit_id => current_user.unit_id)
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @menu_card }
    end
  end

  # GET /menu_cards/1/edit
  def edit
    @menu_card = MenuCard.find(params[:id])
    @current_user_id = get_current_user_id()
    @current_user_info = UserManagement::get_current_user(@current_user_id)
    @sections = Section.where(:unit_id => @menu_card.unit_id)
  end

  # POST /menu_cards
  # POST /menu_cards.json
  def create
    @menu_card = MenuCard.new(params[:menu_card])

    respond_to do |format|
      if @menu_card.save
        format.js
        format.html { redirect_to menu_cards_path, notice: 'Catalog was successfully created.' }
        format.json { render json: @menu_card, status: :created, location: @menu_card }
      else

        format.html { render action: "new" }
        format.json { render json: @menu_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /menu_cards/1
  # PUT /menu_cards/1.json
  def update
    begin
      puts params
      @menu_card = MenuCard.find(params[:id])
      if @menu_card.update_attributes(params[:menu_card])
        @menu_card.reload
        #redirect_to :back, notice: 'Catalog was successfully updated.'
        respond_to do |format|
          format.html { redirect_to :back, notice: 'Catalog was successfully updated.' }
          format.js
        end
      else
        @validation_errors = error_messages_for(@menu_card)
        raise @validation_errors
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to :back, alert: e.message.to_s
    end
  end

  # DELETE /menu_cards/1
  # DELETE /menu_cards/1.json
  def destroy
    @menu_card = MenuCard.find(params[:id])
    @menu_card.destroy

    respond_to do |format|
      format.html { redirect_to menu_cards_url , notice: 'Catalog was permanently Deleted.'}
      format.json { head :no_content }
    end
  end

  def thirdparty_outlet_upload
    @thirdparty_dtl = ThirdpartyConfiguration.find(params[:thirdparty_configuration_id])
    @unit = Unit.find(params[:unit_id])
    @child_menu_card = MenuCard.find(params[:menu_card_id])
    @child_section = @child_menu_card.section
    @child_menu_products = @child_menu_card.menu_products
    @master_section = Section.find(@child_section.master_section_id)
    @master_menu_card = MenuCard.set_section(@master_section.id).active
    @unique_master_munu_categories = @master_menu_card[0].menu_products.select("distinct on (menu_category_id) *")

    _child_product_ids =[]
    if params[:menu_product_ids].present? && JSON.parse(params[:menu_product_ids]).count > 0
      JSON.parse(params[:menu_product_ids]).each do |i|
        _child_product_ids.push(i)
      end
      @child_menu_products = MenuProduct.set_menu_product_in(_child_product_ids)      
    end
    
    if @child_menu_products.count >1000
      redirect_to menu_cards_url , alert: "Urbanpiper support maximun 1000 items to upload."
    else
      # WORK HERE START
      @urban_menu={}
      @urban_menu["categories"]=[]
      @unique_master_munu_categories.each do |umc|
        @menu_category = MenuCategory.find(umc.menu_category_id)
        @urban_categories={}
        @urban_categories["ref_id"] = @menu_category.id
        @urban_categories["name"] = @menu_category.name
        @urban_categories["description"] = @menu_category.description.present? ? @menu_category.description : nil
        @urban_categories["sort_order"] = 1
        @urban_categories["active"] = @menu_category.is_visible
        @urban_categories["img_url"] = @menu_category.menu_category_image.present? ? @my_site_url+@menu_category.menu_category_image : nil
        @urban_menu["categories"].push(@urban_categories)
      end
      @urban_menu["items"]=[]
      @option_g_arr=[]
      @option_arr=[]
      @option_group_id_arr=[]
      @taxes=[]
      @charges=[]
      @child_menu_products.each do |cmp|
        @row_product = cmp.product
        mp = MenuProduct.find_by_menu_card_id_and_product_id(@master_menu_card[0].id,@row_product.id)
        puts "******"
        puts mp.inspect
        if mp.present?
          @urban_items={}
          @urban_items["ref_id"] = mp.id
          @urban_items["title"] = @row_product.name
          @urban_items["available"] = true #mp.stock_status == 1 ? true : false
          if @thirdparty_dtl.is_product_desc.present?
            if @thirdparty_dtl.is_product_desc == "1"
              if @row_product.short_description.present?
                @urban_items["description"] = @row_product.short_description
              else
                @urban_items["description"] = nil
              end
            else
              @urban_items["description"] = nil
            end
          else
            @urban_items["description"] = nil
          end
          @urban_items["sold_at_store"] = true
          @urban_items["price"] = mp.sell_price_without_tax
          @urban_items["current_stock"] = -1 #mp.stock_qty.to_i
          @urban_items["recommended"] = true
          if @row_product.product_religion.present? && @row_product.product_religion.name.downcase == "vegetarian"
            @urban_items["food_type"] = "1"
          elsif @row_product.product_religion.present? && @row_product.product_religion.name.downcase == "non-vegetarian"
            @urban_items["food_type"] = "2"
          elsif @row_product.product_religion.present? && @row_product.product_religion.name.downcase == "eggetarian"
            @urban_items["food_type"] = "3"
          else
            @urban_items["food_type"] = "4"
          end
          _image = @row_product.product_images.first
          _image_url = _image.present? ? "http://#{@my_site_url}#{_image.image.url(:"original")}" : ""

          if @thirdparty_dtl.is_product_image.present?
            if @thirdparty_dtl.is_product_image == "1"
              @urban_items["img_url"] = _image_url
            else
              @urban_items["img_url"] = nil
            end
          else
            @urban_items["img_url"] = nil
          end
          @urban_items["category_ref_ids"] = ["#{mp.menu_category_id}"]

          _menu_product_tags = mp.tags
          _menu_product_tag_group_ids = []
          if _menu_product_tags.present?
            _menu_product_tags.each do |tag|
              if tag.tag_group.present?
                if !(_menu_product_tag_group_ids.include? tag.tag_group.id)
                  _menu_product_tag_group_ids.push tag.tag_group.id
                end
              end
            end
          end

          if _menu_product_tag_group_ids.count > 0
            @urban_items["tags"] = {}
            _menu_product_tag_group_ids.each do |tag_group_id|
              _tag_arr = []
              _tag_group = TagGroup.find(tag_group_id)
              _menu_product_tags.each do |tag|
                if tag.tag_group.present?
                  if tag.tag_group.id == tag_group_id
                    _tag_arr.push tag.name
                  end
                end
              end
              @urban_items["tags"]["#{_tag_group.name}"] = _tag_arr
            end
          end

          @urban_menu["items"].push(@urban_items)
        end
      end


      respond_to do |format|
        format.html { redirect_to menu_cards_url , notice: "#{@urban_menu.to_json}" }
      end
      # WORK HERE END
    end
  end

  def manage_settings
    @com_rules = CombinationsRule.all
    @combinations_rule = CombinationsRule.new
    @com_types = CombinationType.all
    @combination_type = CombinationType.new
  end

  def trash
    menu_card = MenuCard.find(params[:id])
    menu_card[:trash] = 1
    menu_card.save

    respond_to do |format|
      format.html { redirect_to menu_cards_url , notice: 'Menu card was successfully Trashed.' }
      format.json { head :no_content }
    end
  end

  def add_products
    @menu_card = MenuCard.find(params[:id])
    @category = MenuCategory.new
    @root_categories = MenuCategory.get_menu_categories(@menu_card.id).get_root_categories
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    @inventory_status = AppConfiguration.get_config_value('inventory_module')
    @combination_types = CombinationType.all
    _menu_products = MenuProduct.by_menu_card(@menu_card.id).pluck(:product_id)
    
    @menu_categories = @menu_card.menu_categories
    @menu_card_products = @menu_card.menu_products.order("menu_category_id asc")
    @menu_card_products = @menu_card_products.filter_by_string(params[:filter]) if params[:filter].present?
    @menu_card_products = @menu_card_products.filter_by_menu_category(params[:menu_category]) if params[:menu_category].present?
    @menu_card_products = @menu_card_products.filter_by_sku(@menu_card_products,params[:sku_filter]) if params[:sku_filter].present?

    product_scope = Product.get_all
    product_scope = product_scope.product_not_in(_menu_products) if _menu_products.present?
    product_scope = product_scope.combo_product if params[:mproduct_type].present? and params[:mproduct_type] == "combo_product"
    product_scope = product_scope.set_category(params[:catrgory]) if params[:catrgory]
    product_scope = product_scope.filter_by_string(params[:filter]) if params[:filter].present?
    smart_listing_create :products, product_scope, partial: "menu_cards/add_product_smartlist", default_sort: {id: "desc"}
    smart_listing_create :addon_products, product_scope, partial: "menu_cards/add_addon_product_smartlist", default_sort: {id: "desc"}
    smart_listing_create :menu_card_combo_items, @menu_card_products, partial: "menu_cards/menu_card_combo_items_smartlist", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  def outlet_menu_association
    @menu_cards = MenuCard.where( master_menu_id: nil)
  end

  def master_mode_toggle
    menu_card = MenuCard.find(params[:id])
    MenuCard.each_mode_toggle(menu_card[:id])
    unit_menu_cards = MenuCard.where(master_menu_id: params[:id])

    unit_menu_cards.each do |unit_menu_card|
      MenuCard.each_mode_toggle(unit_menu_card[:id])
    end

    respond_to do |format|
      format.html { redirect_to outlet_menu_association_menu_cards_path , notice: 'You have successfully changed the menu card status.' }
    end
  end

  def copy
    @menu_card = MenuCard.find(params[:id])
    @clone_menu = MenuCard.new
  end

  def clone
    begin
      @master_card = MenuCard.find(params[:id])
      ActiveRecord::Base.transaction do # Protective transaction block
        @menu_card = MenuCard.new(params[:menu_card])
        @menu_card.save
      end
      redirect_to copy_menu_card_path(@master_card), notice: "Catalog successfully cloned (ID: #{@menu_card.id})"
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to copy_menu_card_path(@master_card), alert: e.message.to_s
    end
  end

  def update_mode
    @lot = Lot.find(params[:lot_id])
    _mode = @lot.mode == 0 ? 1 : 0
    @lot.update_attributes(:mode => _mode)

    respond_to do |format|
      format.json { render json: @lot }
    end
  end

  def allocate_sale_rules_to_lots
    begin
      raise 'No Rules checkbox selected' unless params[:selected_sale_rules].present?
      ActiveRecord::Base.transaction do
        prev = LotSaleRule.where('lot_id =?', params[:lot_id])
        prev.destroy_all if prev.present?
        params[:selected_sale_rules].each do |sale_rule|
          _lot_sale_rule = LotSaleRule.create(:lot_id=>params[:lot_id],:sale_rule_id=>sale_rule)
        end
      end  
      redirect_to menu_card_path(params[:id]), notice: "Sale Rules successfully added to Lot" 
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to menu_card_path(params[:id]), alert: e.message.to_s      
    end
  end

  def allocate_sale_rules_to_menu_products
    puts params
    begin
      raise 'No Rules checkbox selected' unless params[:selected_sale_rules].present?
      ActiveRecord::Base.transaction do
        prev = MenuProductSaleRule.where('menu_product_id =?', params[:menu_product_id])
        prev.destroy_all if prev.present?
        params[:selected_sale_rules].each do |sale_rule|
          _menu_product_sale_rule = MenuProductSaleRule.create(:menu_product_id=>params[:menu_product_id],:sale_rule_id=>sale_rule,:menu_card_id=>params[:id])
        end
      end  
      redirect_to menu_card_path(params[:id]), notice: "Sale Rules successfully added to Menu Product" 
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to menu_card_path(params[:id]), alert: e.message.to_s      
    end
  end

  def get_categories
    @brands = Product.uniq.pluck(:brand_name)
    @category_type = params[:category_type]
    @sale_rules = SaleRule.all
    @menu_card = MenuCard.find(params[:id])
    @current_user_id = get_current_user_id()
    @current_user_info = UserManagement::get_current_user(@current_user_id)
    @menu_categories = MenuCategory.all
    @menu_category = MenuCategory.new
    @categories = @menu_card.menu_categories
    @product_brands = Product.select("DISTINCT(brand_name)")
    @product_brands = @product_brands.brand_like(params[:brand]) if params[:brand].present?
    @product_brands = @product_brands.set_product_brands(params[:product_brands]) if params[:product_brands].present?
    smart_listing_create :brands, @product_brands, partial: "products/product_brands_smartlist"
    smart_listing_create :brands_with_category, @product_brands, partial: "products/product_brands_with_category_smartlist"

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def sale_price_update_by_category
    increase_by_sp = params[:increase_by_sp]
    decrease_by_sp = params[:decrease_by_sp]
    decrease_by_mrp = params[:decrease_by_mrp]
    if increase_by_sp.empty?
      increase_by_sp = 0
    end
    if decrease_by_sp.blank?
      decrease_by_sp = 0
    end
    if decrease_by_mrp.empty?
      decrease_by_mrp = 0
    end
    menu_category = MenuCategory.by_id(params[:menu_category_id])
    if menu_category.parent.blank?
      if menu_category.submenucategories.present?
        menu_sub_categories = menu_category.submenucategories
        menu_sub_categories.each do |menu_sub_category|
          menu_products = MenuProduct.by_menu_card(params[:menu_card_id]).filter_by_menu_category(menu_sub_category.id)
        end
      end
    else
      menu_products = MenuProduct.by_menu_card(params[:menu_card_id]).filter_by_menu_category(params[:menu_category_id])
    end
    if menu_products.present?
      menu_products.each do |menu_product|
        sale_price_without_tax = menu_product.sell_price_without_tax.to_f
        new_sale_price_without_tax = sale_price_without_tax * (100 + increase_by_sp.to_f) / 100
        new_sale_price_without_tax = new_sale_price_without_tax * (100 - decrease_by_sp.to_f) / 100
        menu_product.update_attributes(:sell_price_without_tax => new_sale_price_without_tax)
        menu_product.assign_tax_group
        # lots = menu_product.lots.by_menu_card(params[:menu_card_id])
        lots = menu_product.product.lots.by_store(menu_product.store_id)
        if lots.present?
          lots.each do |lot|
            lot_sell_price_without_tax = lot.sell_price_without_tax.to_f
            new_lot_sell_price_without_tax = lot_sell_price_without_tax * (100 + increase_by_sp.to_f) / 100
            new_lot_sell_price_without_tax = new_lot_sell_price_without_tax * (100 - decrease_by_sp.to_f) / 100
            lot.update_attributes(:sell_price_without_tax => new_lot_sell_price_without_tax)
            lot.update_tax_group
            # mrp change
            lot_mrp = lot.mrp.to_f
            new_lot_mrp = lot_mrp * (100 - decrease_by_mrp.to_f) / 100
            lot.update_attributes(:mrp => new_lot_mrp) 
          end
        end
      end
    end
    respond_to do |format|
      format.json { render json: menu_category }
    end
  end

  def sale_price_update_by_brand_name
    @all_lots = Array.new
    @lot = {}
    sp_increase_by_brand_name = params[:sp_increase_by_brand_name]
    sp_decrease_by_brand_name = params[:sp_decrease_by_brand_name]
    mrp_decrease_by_brand_name = params[:mrp_decrease_by_brand_name]
    if sp_increase_by_brand_name.empty?
      sp_increase_by_brand_name = 0
    end
    if sp_decrease_by_brand_name.blank?
      sp_decrease_by_brand_name = 0
    end
    # if mrp_decrease_by_brand_name.blank?
    #   mrp_decrease_by_brand_name = 0
    # end

    products = Product.by_brand_name(params[:brand_name])
    @all_lots = Array.new
    if products.present?
      products.each do |product|
        # menu_products = MenuProduct.by_menu_card(params[:menu_card_id]).set_product(product.id)
        menu_product = MenuProduct.find_by_menu_card_id_and_product_id(params[:menu_card_id],product.id)
        if menu_product.present?
          sale_price = menu_product.sell_price.to_f
          new_sale_price = sale_price * (100 + sp_increase_by_brand_name.to_f) / 100
          new_sale_price = new_sale_price * (100 - sp_decrease_by_brand_name.to_f) / 100
          menu_product.update_attributes(:sell_price => new_sale_price)
          #menu_product.assign_tax_group
          _total_amnt = 0
          # menu_product.tax_group.tax_classes.each do |tc|
          up = UnitProduct.by_unit(menu_product.store.unit_id).by_product(product.id)
          if up.present?
            up.first.tax_group.tax_classes.each do |tc|
              if tc.tax_type == 'variable'
                if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(menu_product.sell_price.to_f)
                  _total_amnt = _total_amnt + tc[:ammount].to_f
                end 
              else
                _total_amnt = _total_amnt + tc[:ammount].to_f  
              end
            end
          end
          new_sale_price_without_tax = 0
          new_sale_price_without_tax = (menu_product.sell_price.to_f * 100)/(_total_amnt.to_f + 100)
          menu_product.update_attributes(:sell_price_without_tax => new_sale_price_without_tax)
          # lots = menu_product.lots.by_menu_card(params[:menu_card_id])
          lots = menu_product.product.lots.by_store(menu_product.store_id)
          if lots.present?
            lots.each do |lot|
              @lot["#{lot.id}"] = {}
              @lot["#{lot.id}"][:prev_sell_price] = lot.sell_price
              @lot["#{lot.id}"][:product_name] = menu_product.product.name
              @lot["#{lot.id}"][:landing_price] = lot.stock.stock_price.landing_price
              if mrp_decrease_by_brand_name.blank?
                lot_sell_price = lot.sell_price.to_f
                new_lot_sell_price = lot_sell_price * (100 + sp_increase_by_brand_name.to_f) / 100
                new_lot_sell_price = new_lot_sell_price * (100 - sp_decrease_by_brand_name.to_f) / 100
                lot.update_attributes(:sell_price => new_lot_sell_price)
                #lot.update_tax_group
                _total_tax_amnt = 0
                lot.tax_group.tax_classes.each do |tc|
                  if tc.tax_type == 'variable'
                    if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(lot.sell_price.to_f)
                      _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f
                    end 
                  else
                    _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f  
                  end
                end
                new_lot_sale_price_without_tax = 0
                new_lot_sale_price_without_tax = (lot.sell_price.to_f * 100)/(_total_tax_amnt.to_f + 100)
                lot.update_attributes(:sell_price_without_tax => new_lot_sale_price_without_tax)
              # mrp change
              else
                lot_mrp = lot.mrp.to_f
                new_lot_mrp = lot_mrp * (100 - mrp_decrease_by_brand_name.to_f) / 100
                # lot.update_attributes(:mrp => new_lot_mrp)
                lot.update_attributes(:sell_price => new_lot_mrp)
                #lot.update_tax_group
                _total_tax_amnt = 0
                lot.tax_group.tax_classes.each do |tc|
                  if tc.tax_type == 'variable'
                    if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(lot.sell_price.to_f)
                      _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f
                    end 
                  else
                    _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f  
                  end
                end
                new_lot_sale_price_without_tax = 0
                new_lot_sale_price_without_tax = (lot.sell_price.to_f * 100)/(_total_tax_amnt.to_f + 100)
                lot.update_attributes(:sell_price_without_tax => new_lot_sale_price_without_tax)
              end
              @lot["#{lot.id}"][:new] = lot
              @all_lots.push @lot
            end
          end
        end
      end
    end
    respond_to do |format|
      format.json { render json: @all_lots }
    end
  end

  # sale_price_update_by_brand_name_and_category

  def sale_price_update_by_brand_name_and_category
    @all_lots = Array.new
    @lot = {}
    sp_increase_by_brand_name_category = params[:sp_increase_by_brand_name_category]
    sp_decrease_by_brand_name_category = params[:sp_decrease_by_brand_name_category]
    mrp_decrease_by_brand_name_category = params[:mrp_decrease_by_brand_name_category]
    if sp_increase_by_brand_name_category.empty?
      sp_increase_by_brand_name_category = 0
    end
    if sp_decrease_by_brand_name_category.blank?
      sp_decrease_by_brand_name_category = 0
    end
    # if mrp_decrease_by_brand_name_category.blank?
    #   mrp_decrease_by_brand_name_category = 0
    # end
    menu_category = MenuCategory.find(params[:menu_category_id])
    menu_products = menu_category.menu_products.by_menu_card(params[:menu_card_id])
    if menu_products.present?
      menu_products.each do |menu_product|
        if Product.find(menu_product.product_id).brand_name == params[:brand_name]
          sale_price = menu_product.sell_price.to_f
          new_sale_price = sale_price * (100 + sp_increase_by_brand_name_category.to_f) / 100
          new_sale_price = new_sale_price * (100 - sp_decrease_by_brand_name_category.to_f) / 100
          menu_product.update_attributes(:sell_price => new_sale_price)
          #menu_product.assign_tax_group
          _total_amnt = 0
          # menu_product.tax_group.tax_classes.each do |tc|
          up = UnitProduct.by_unit(menu_product.store.unit_id).by_product(product.id)
          if up.present?
            up.first.tax_group.tax_classes.each do |tc|
              if tc.tax_type == 'variable'
                if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(menu_product.sell_price.to_f)
                  _total_amnt = _total_amnt + tc[:ammount].to_f
                end 
              else
                _total_amnt = _total_amnt + tc[:ammount].to_f  
              end
            end
          end
          new_sale_price_without_tax = 0
          new_sale_price_without_tax = (menu_product.sell_price.to_f * 100)/(_total_amnt.to_f + 100)
          menu_product.update_attributes(:sell_price_without_tax => new_sale_price_without_tax)
          # lots = menu_product.lots.by_menu_card(params[:menu_card_id])
          lots = menu_product.product.lots.by_store(menu_product.store_id)
          if lots.present?
            lots.each do |lot|
              @lot["#{lot.id}"] = {}
              @lot["#{lot.id}"][:prev_sell_price] = lot.sell_price
              @lot["#{lot.id}"][:product_name] = menu_product.product.name
              @lot["#{lot.id}"][:landing_price] = lot.stock.stock_price.landing_price
              if mrp_decrease_by_brand_name_category.blank?
                lot_sell_price = lot.sell_price.to_f
                new_lot_sell_price = lot_sell_price * (100 + sp_increase_by_brand_name_category.to_f) / 100
                new_lot_sell_price = new_lot_sell_price * (100 - sp_decrease_by_brand_name_category.to_f) / 100
                lot.update_attributes(:sell_price => new_lot_sell_price)
                #lot.update_tax_group
                _total_tax_amnt = 0
                lot.tax_group.tax_classes.each do |tc|
                  if tc.tax_type == 'variable'
                    if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(lot.sell_price.to_f)
                      _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f
                    end 
                  else
                    _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f  
                  end
                end
                new_lot_sale_price_without_tax = 0
                new_lot_sale_price_without_tax = (lot.sell_price.to_f * 100)/(_total_tax_amnt.to_f + 100)
                lot.update_attributes(:sell_price_without_tax => new_lot_sale_price_without_tax)
              # mrp change
              else
                lot_mrp = lot.mrp.to_f
                new_lot_mrp = lot_mrp * (100 - mrp_decrease_by_brand_name_category.to_f) / 100
                # lot.update_attributes(:mrp => new_lot_mrp)
                lot.update_attributes(:sell_price => new_lot_mrp)
                #lot.update_tax_group
                _total_tax_amnt = 0
                lot.tax_group.tax_classes.each do |tc|
                  if tc.tax_type == 'variable'
                    if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(lot.sell_price.to_f)
                      _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f
                    end 
                  else
                    _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f  
                  end
                end
                new_lot_sale_price_without_tax = 0
                new_lot_sale_price_without_tax = (lot.sell_price.to_f * 100)/(_total_tax_amnt.to_f + 100)
                lot.update_attributes(:sell_price_without_tax => new_lot_sale_price_without_tax)
              end
              @lot["#{lot.id}"][:new] = lot
              @all_lots.push @lot
            end
          end
        end
      end
    end

    respond_to do |format|
      format.json { render json: @all_lots }
    end
  end

  def add_rule_with_category_and_brand
    begin
      raise 'No Rules checkbox selected' unless params[:selected_sale_rules].present?
      ActiveRecord::Base.transaction do
        menu_category = MenuCategory.find(params[:menu_category_id])
        menu_products = menu_category.menu_products.by_menu_card(params[:menu_card_id])

        if menu_products.present?
          menu_products.each do |menu_product|
            if Product.find(menu_product.product_id).brand_name == params[:brand_name]
              lots = menu_product.lots.by_menu_card(params[:menu_card_id])
              if lots.present?
                lots.each do |lot|
                  prev = LotSaleRule.where('lot_id =?', lot.id)
                  prev.destroy_all if prev.present?
                  params[:selected_sale_rules].each do |sale_rule|
                    _lot_sale_rule = LotSaleRule.create(:lot_id=>lot.id,:sale_rule_id=>sale_rule)
                  end
                end
              end
            end
          end
        end
      end  
      # redirect_to menu_card_path(params[:id]), notice: "Sale Rules successfully added to Lot" 
      redirect_to "#{get_categories_menu_card_path(params[:id])}?category_type=#{'brand_name_and_category'}", notice: "Sale Rules successfully added to Lot"
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to "#{get_categories_menu_card_path(params[:id])}?category_type=#{'brand_name_and_category'}", alert: e.message.to_s      
    end
  end

  private

  def set_module_details
    @module_id = "menu_cards"
    @module_title = I18n.t(:calatog_title)
  end

end
