class MenuProductsController < ApplicationController
  load_and_authorize_resource :except => [:mode_toggle]
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  layout "material"

  before_filter :set_module_details

  require 'rest-client'
  require 'json'
  require 'date'

  # GET /menu_products
  # GET /menu_products.json
  def index
    #@menu_products = MenuProduct.all
    @lots = Lot.all
    products = Product.by_brand_name(params[:brand]).map{|product| product.id}.flatten if params[:brand].present?
    #@menu_products = MenuProduct.where(:product_id =>products,:menu_card_id=>params[:menu_card]) if lots.present?
    @lots = Lot.where(:product_id => products, :menu_card_id=>params[:menu_card]) if products.present?
    smart_listing_create :menu_card_lots, @lots, partial: "lots/menu_product_lot_listing", default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @menu_products.to_json(:include => [:variants]) }
    end
  end

  # GET /menu_products/1
  # GET /menu_products/1.json
  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :GET, '/menu_products/:id', "Show menu product details BY ID"
  error :code => 401, :desc => "Unauthorized"
  param :id, :number
  #param :session, String, :desc => "user is logged in", :required => true
  description "URL : http://lazeez.stewot.com/menu_products/8.json?device_id=YOTTO05"
  formats ['json', 'jsonp']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def show
    @menu_product = MenuProduct.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @menu_product.to_json(:include =>
                        [ {:tax_group => {:include => :tax_classes}}, {:variants =>{:include =>
                            [{:product => {:include => :product_meta} },
                              {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types]}},

                          {:product => {:include => :product_meta} },
                            {:menu_product_combinations => {:include => :product}}, :combinations_rules, :combination_types
                        ] ) }
    end
  end

  # GET /menu_products/new
  # GET /menu_products/new.json
  def new
    @menu_product = MenuProduct.new
    @menu_card_id = params[:menu_card_id]
    @menu_card = MenuCard.find(params[:menu_card_id])
    # @menu_categories = MenuCategory.find(:all, :conditions => { menu_card_id: @menu_card_id }, :include => :submenucategories)
    @menu_categories = MenuCategory.where(menu_card_id: @menu_card_id ).includes(:submenucategories)
    # @have_products = MenuProduct.find(:all, :conditions => ["menu_card_id =?", @menu_card_id])
    @have_products = MenuProduct.where(:menu_card_id => @menu_card_id)
    #  ########    Deprecated for showing products under category ##################
    # @products = MenuProduct.get_products(@have_products, "simple")
    # @variable_products = MenuProduct.get_products(@have_products, "variable")
    # @combo_products = MenuProduct.get_products(@have_products, "combo")
    @products = MenuProduct.get_products("simple")
    @variable_products = MenuProduct.get_products("variable")
    @combo_products = MenuProduct.get_products("combo")
    # ################################################################################

    @variable_menu_products = MenuProduct.get_menu_products(@menu_card_id, "variable")
    @combo_menu_products = MenuProduct.get_menu_products(@menu_card_id, "combo")
    @all_products = Product.all
    @categories = MenuCategory.get_menu_categories(@menu_card_id)
    @menu_category = MenuCategory.new
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    # @owner_will_crud_menu = AppConfiguration.find(:first, :conditions => ['config_key =?', "owner_will_crud_menu"])
    @units = Unit.all
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @menu_product }
    end
  end

  # fetch sub menu products of a group produuct
  def find_sub_menu_products
    @id = params[:id]
    @type_prio = Product.where(:parent => @id)
    respond_to do |format|
      format.json { render :json => @type_prio}
    end
  end

  # thirdparty item action
  def thirdparty_item_action
    @menu_product_ids = params[:menu_product_ids]
    @thirdparty_item_actions = ThirdpartyItemAction.menu_product_id_in(@menu_product_ids)
    respond_to do |format|
      format.json { render :json => @thirdparty_item_actions}
    end
  end

  def copy_menu
    MenuManagement::copy_menu(params[:copy_from_id], params[:copy_to_id])

    respond_to do |format|
      format.json { render :json => @menu_details}
    end
  end

  def mode_toggle
    @id = params[:id]
    @menu_product = MenuProduct.find(params[:id])
    @mode = @menu_product[:mode]
    if @mode == 0
      @menu_product.mode = 1
      @menu_product.save
      @msg = "1"
    else
      @menu_product.mode = 0
      @menu_product.save
      @msg = "2"
    end
    respond_to do |format|
      format.json { render :json => @msg}
    end
  end

  # GET /menu_products/1/edit
  def edit
    @menu_product = MenuProduct.find(params[:id])
    #@menu_categories = MenuCategory.find(:all, :conditions => { menu_card_id: @menu_product[:menu_card_id] }, :include => :submenucategories)
    @menu_categories = MenuCategory.where(menu_card_id: @menu_product[:menu_card_id]).includes(:submenucategories)
    @combination_types = CombinationType.all
    @combination_rules = CombinationsRule.all
    @combinations_products = Product.get_all
    @menu_product_combinations = MenuProductCombination.where(:menu_product_id => params[:id])
    @menu_product_combinations_type_arr = Array.new
    @menu_product_combinations.each do |mpc|
      @menu_product_combinations_type_arr.push mpc[:combination_type_id]
    end
    @owner_will_crud_menu = AppConfiguration.get_config_value('owner_will_crud_menu')
    # @owner_will_crud_menu = AppConfiguration.find(:first, :conditions => ['config_key =?', "owner_will_crud_menu"])
    @units = Unit.all
    @variable_menu_products = MenuProduct.get_menu_products(@menu_product[:menu_card_id], "variable")
    @combo_menu_products = MenuProduct.get_menu_products(@menu_product[:menu_card_id], "combo")
  end

  # POST /menu_products
  # POST /menu_products.json
  def create
    @menu_product = MenuProduct.new(params[:menu_product])

    if params[:product_type] == 'variable'
      @menu_product[:stock_qty] = 0
    end
    combination_type_ids = params[:checked_comb]

    @menu_product.save
    if !combination_type_ids.nil?
      combination_type_ids.each do |combination_type_id|
        product_id = params["ct#{combination_type_id}rp"]
        combinations_rule_id = params["rule_#{combination_type_id}"]
        product_id.each do |p_id|
          price = params["ct#{combination_type_id}price#{p_id}"]
          ammount = params["ct#{combination_type_id}ammount#{p_id}"]
          product_unit = params["ct#{combination_type_id}product_unit#{p_id}"]
          MenuManagement::create_menu_product(p_id, price, ammount, product_unit, @menu_product.id, combination_type_id, combinations_rule_id)
        end
      end
    end


    respond_to do |format|
      if @menu_product.save
        format.html { redirect_to :back, notice: 'Menu product was successfully added.' }
        format.json { render json: @menu_product, status: :created, location: @menu_product }
      else
        format.html { render action: "new" }
        format.json { render json: @menu_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /menu_products/1
  # PUT /menu_products/1.json
  def update
    params[:menu_product][:tag_ids] ||= []
    puts params
    @menu_product = MenuProduct.find(params[:id])

    MenuProductCombination.destroy_all("menu_product_id = #{params[:id]}")
    combination_type_ids = params[:checked_comb]
    if !combination_type_ids.nil?
      combination_type_ids.each do |combination_type_id|
        # product_id = params["ct#{combination_type_id}rp"]
        combinations_rule_id = params["rule_#{combination_type_id}"]

        # product_id.each do |p_id|
        #   price = params["ct#{combination_type_id}price#{p_id}"]
        #   ammount = params["ct#{combination_type_id}ammount#{p_id}"]
        #   product_unit = params["ct#{combination_type_id}product_unit#{p_id}"]
        #   MenuManagement::create_menu_product(p_id, price, ammount, product_unit, @menu_product.id, combination_type_id, combinations_rule_id)
        # end
        addon_group_ids = params["ct#{combination_type_id}ag"]
        if !addon_group_ids.nil?
          addon_group_ids.each do |ag_id|
            addons_group = AddonsGroup.find(ag_id)
            addons_group_products = addons_group.addons_group_products
            if addons_group_products.present?
              addons_group_products.each do |ag_p|
                price = ag_p.price
                ammount = ag_p.ammount
                product_unit = ag_p.product_unit_id
                MenuManagement::create_menu_product(ag_p.product_id, price, ammount, product_unit, @menu_product.id, combination_type_id, combinations_rule_id, ag_id, ag_p.id)
              end
            end
          end
        end

      end
    end

    respond_to do |format|
      if @menu_product.update_attributes(params[:menu_product])
        format.html { redirect_to new_menu_product_path+"?menu_card_id=#{@menu_product[:menu_card_id]}", notice: 'Menu product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @menu_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def thirdparty_upload
    @thirdparty_dtl = ThirdpartyConfiguration.find(params[:thirdparty_configuration_id]) 

    # MIGRATION CODE START HERE
    @message_arr = []
    if @thirdparty_dtl.thirdparty == "urban_piper"  # URBANPIPER START HERE
      @menu_card = MenuCard.find(params[:menu_card_id])
      if params[:unit_id].present?  # UNIT SELECTED
        _unit_ids =[]
        _unit_ids = params[:unit_id]
        if params[:up_item_id].present? && JSON.parse(params[:up_item_id]).count > 0 # ITEM SELECED
          _unit_ids.each do |_unit_id| # UNIT LOOP
            @menu_products = @menu_card.menu_products.not_deleted
            _p_ids =[]
            JSON.parse(params[:up_item_id]).each do |i|
              _p_ids.push(i)
            end
            @menu_products = MenuProduct.set_menu_product_in(_p_ids)
            @tax_class_ids = []
            @menu_products.each do |po|
              po.tax_group.tax_classes.each do |tc|
                if !(@tax_class_ids.include? tc.id)
                  @tax_class_ids.push(tc.id)
                end
              end
            end
            @menu_product_ids = @menu_products.map { |e| e.id } 
            @unique_munu_cat_p = @menu_card.menu_products.select('distinct on (menu_category_id) *')   # TO GET UNIQUE MENU CATEGORY ID
            @unique_munu_cat = []
            @unique_munu_cat_p.each do |m_cat_id|
              @unique_munu_cat.push(m_cat_id.menu_category_id)
            end
            @unique_parent_menu_cat = []
            @unique_munu_cat.each do |ucid|
              @menu_c_category = MenuCategory.find(ucid)
              if @menu_c_category.parent.present? && @menu_c_category.is_parent_visible.present?
                if !(@unique_parent_menu_cat.include? @menu_c_category.parent)
                  if @menu_c_category.is_parent_visible
                    @unique_parent_menu_cat.push(@menu_c_category.parent)
                  end
                end
              end
            end
            @unique_munu_cat = @unique_munu_cat + @unique_parent_menu_cat
            @urban_menu={}
            @urban_menu["categories"]=[]
            @unique_munu_cat.each do |umc| 
              @menu_category = MenuCategory.find(umc)
              @urban_categories={}
              @urban_categories["ref_id"] = @menu_category.id.to_s
              if @menu_category.parent.present?
                if @menu_category.is_parent_visible == true
                  @urban_categories["parent_ref_id"] = @menu_category.parent.to_s
                end
              end
              @urban_categories["name"] = @menu_category.name
              if @menu_category.description.present?
                @urban_categories["description"] = @menu_category.description
              end
              if @menu_category.sort_order.present?
                @urban_categories["sort_order"] = @menu_category.sort_order
              end
              @urban_categories["active"] = @menu_category.is_visible
              if @menu_category.menu_category_image.present?
                @urban_categories["img_url"] = "#{@my_site_url}#{@menu_category.menu_category_image}"
              end
              @urban_menu["categories"].push(@urban_categories)
            end
            @urban_menu["flush_items"] = false
            @urban_menu["items"]=[]
            @option_g_arr=[]
            @option_arr=[]
            @option_group_id_arr=[]
            @taxes=[]
            @charges=[]
            @menu_products.each do |mp| # MENU PRODUCT LOOP START
              if mp.mode == 1 # MENU PRODUCT MODE ACTIVE CHECK
                @urban_items={}
                @urban_items["ref_id"] = mp.id.to_s
                @urban_items["title"] = mp.product.name
                _child_mp = MenuProduct.find(mp.id).child_menu_product(_unit_id)
                if _child_mp.present?
                  if _child_mp.sold_at_store
                    @urban_items["sold_at_store"] = true
                    @urban_items["available"] = _child_mp.mode == 1 ? true : false
                  else
                    @urban_items["sold_at_store"] = false
                    @urban_items["available"] = false
                  end
                  @urban_items["price"] = _child_mp.sell_price_without_tax
                  @urban_items["current_stock"] = -1
                else
                  @urban_items["available"] = false
                  @urban_items["price"] = mp.sell_price_without_tax
                  @urban_items["sold_at_store"] = false
                  @urban_items["current_stock"] = -1
                end
                @urban_items["category_ref_ids"] = ["#{mp.menu_category_id.to_s}"]

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
              end # MENU PRODUCT ACTIVE MODE END
            end # MENU PRODUCT LOOP END
            @menu_card_option_groups = AddonsGroup.set_section(@menu_card.section.id)
            @menu_card_option_groups.each do |mcog| # MENU CARD ADDONS GROUP LOOP
              @option_group_id_arr.push(mcog.id)
              @options_g_hash={}
              @options_g_hash["ref_id"] = mcog.id.to_s
              @options_g_hash["title"] = mcog.title
              @options_g_hash["min_selectable"] = mcog.min_selectable.present? ? mcog.min_selectable.to_i : 0
              @options_g_hash["max_selectable"] = mcog.max_selectable.present? ? mcog.max_selectable.to_i : -1
              @options_g_hash["active"] = true
              @options_g_hash["item_ref_ids"] = []
              @options_g_menu_product = MenuProduct.by_menu_card_and_addons_group(params[:menu_card_id], mcog.id)
              @options_g_menu_product.each do |ogmp|
                if ogmp.mode == 1 && JSON.parse(params[:up_item_id]).include?(ogmp.id.to_s)
                  @options_g_hash["item_ref_ids"].push(ogmp.id.to_s)
                end
              end
              @option_g_arr.push(@options_g_hash)
            end # MENU CARD ADDONS GROUP LOOP END
            @urban_menu["option_groups"]=@option_g_arr
            @addons = AddonsGroupProduct.by_addons_group_id_in(@option_group_id_arr)
            @addons.each do |option| # ADDONS LOOP
              if !@option_arr.any? {|h| h[:ref_id] == option.product.id}
                @option_hash={}
                @option_hash["ref_id"] = option.product.id.to_s
                @option_hash["title"] = option.product.name
                @option_hash["description"] = option.product.short_description.present? ? option.product.short_description : nil
                @option_hash["weight"] = option.ammount
                @option_hash["available"] = true
                if @unit_id.to_i > 0
                  _child_addon = AddonsGroupProduct.by_product_and_punit_and_qnt_and_unit(option.product.id, option.product_unit_id, option.ammount, @unit_id).first
                  if _child_addon.present?
                    @option_hash["price"] = _child_addon.price
                  else
                    @option_hash["price"] = option.price
                  end
                else
                  @option_hash["price"] = option.price
                end
                # @option_hash["price"] = option.price
                @option_hash["sold_at_store"] = true
                @option_hash["opt_grp_ref_ids"] =  []
                # @menu_card_1 = MenuCard.find(params[:menu_card_id])
                AddonsGroup.set_product_master_section(option.product.id,current_user.unit.id,@menu_card.section.id).each do |g|
                  @option_hash["opt_grp_ref_ids"].push(g.id.to_s)
                end
                @option_arr.push(@option_hash)
              end
            end # ADDONS LOOP
            @urban_menu["options"]=@option_arr
            @tax_classes=TaxClass.by_tax_classes(@tax_class_ids)
            @tax_classes.each do |tax_class| # TAX CLASS/CHARGES LOOP
              @tax_class_hash={}
              @charge_hash={}
              if tax_class.tax_type == "simple"
                if tax_class.ammount > 0
                  @tax_class_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
                  @tax_class_hash["title"] = tax_class.name
                  @tax_class_hash["description"] = tax_class.name
                  @tax_class_hash["active"] = true
                  @tax_class_hash["structure"] = {}
                    @tax_class_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                    @tax_class_hash["structure"]["applicable_on"]= "item.price"
                    @tax_class_hash["structure"]["value"]= tax_class.ammount
                  @tax_class_hash["item_ref_ids"]=[]
                  @menu_products.each do |tmp|
                    if tmp.tax_group.tax_classes.include? tax_class
                      if tmp.mode == 1 && JSON.parse(params[:up_item_id]).include?(tmp.id.to_s)
                        @tax_class_hash["item_ref_ids"].push(tmp.id.to_s)
                      end
                    end
                  end
                  @taxes.push(@tax_class_hash)
                end
              elsif tax_class.tax_type != "veriable" || tax_class.tax_type != "simple"
                @charge_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
                @charge_hash["title"] = tax_class.name
                @charge_hash["description"] = tax_class.name
                @charge_hash["active"] = true
                @charge_hash["structure"] = {}
                  @charge_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                  @charge_hash["structure"]["applicable_on"]= "item.quantity"
                  @charge_hash["structure"]["value"]= tax_class.ammount
                @charge_hash["item_ref_ids"]=[]
                @menu_products.each do |tmp|
                  if tmp.tax_group.tax_classes.include? tax_class
                    if tmp.mode == 1 && JSON.parse(params[:up_item_id]).include?(tmp.id.to_s)
                      @charge_hash["item_ref_ids"].push(tmp.id.to_s)
                    end
                  end
                end
                @charges.push(@charge_hash)
              end
            end  # TAX CLASS/CHARGES LOOP END
            @urban_menu["taxes"]=@taxes
            @urban_menu["charges"]=@charges
            @urban_menu["callback_url"] = nil # "http://#{@my_site_url}"
            logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON START **************** +"
            logger.debug @urban_menu.to_json
            logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON END **************** +"
            
            @response=ThirdpartyUrbanpiper.thirdparty_urbanpiper_cat_item_upload(@thirdparty_dtl,@urban_menu.to_json,_unit_id)
            logger.debug "+ ******************** URBANPIPER RESPONSE START **************** +"
            logger.debug @response
            logger.debug "+ ******************** URBANPIPER RESPONSE END **************** +"
            if JSON.parse(@response)["status"] == "success"
              if _unit_id.to_i > 0
                @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}" }
                @message_arr.push(@message_hash)
                sleep 7
              else
                @message_hash = {"status" => true, "message" => "Owner master menu." }
                @message_arr.push(@message_hash)
              end
            else
              if _unit_id.to_i > 0
                @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}" }
                @message_arr.push(@message_hash)
                sleep 7
              else
                @message_hash = {"status" => false, "message" => "Owner master menu." }
                @message_arr.push(@message_hash)
              end
            end
          end # UNIT LOOP END
        else # ITEM NOT SELECED                
          _unit_ids.each do |_unit_id| # UNIT LOOP
            @menu_products = @menu_card.menu_products.not_deleted
            @tax_class_ids = []
            @menu_products.each do |po|
              po.tax_group.tax_classes.each do |tc|
                if !(@tax_class_ids.include? tc.id)
                  @tax_class_ids.push(tc.id)
                end
              end
            end
            @menu_product_ids = @menu_products.map { |e| e.id } 
            @unique_munu_cat_p = @menu_card.menu_products.select('distinct on (menu_category_id) *')   # TO GET UNIQUE MENU CATEGORY ID
            @unique_munu_cat = []
            @unique_munu_cat_p.each do |m_cat_id|
              @unique_munu_cat.push(m_cat_id.menu_category_id)
            end
            @unique_parent_menu_cat = []
            @unique_munu_cat.each do |ucid|
              @menu_c_category = MenuCategory.find(ucid)
              if @menu_c_category.parent.present? && @menu_c_category.is_parent_visible.present?
                if !(@unique_parent_menu_cat.include? @menu_c_category.parent)
                  if @menu_c_category.is_parent_visible
                    @unique_parent_menu_cat.push(@menu_c_category.parent)
                  end
                end
              end
            end
            @unique_munu_cat = @unique_munu_cat + @unique_parent_menu_cat
            @urban_menu={}
            @urban_menu["categories"]=[]
            @unique_munu_cat.each do |umc| 
              @menu_category = MenuCategory.find(umc)
              @urban_categories={}
              @urban_categories["ref_id"] = @menu_category.id.to_s
              if @menu_category.parent.present?
                if @menu_category.is_parent_visible == true
                  @urban_categories["parent_ref_id"] = @menu_category.parent.to_s
                end
              end
              @urban_categories["name"] = @menu_category.name
              if @menu_category.description.present?
                @urban_categories["description"] = @menu_category.description
              end
              if @menu_category.sort_order.present?
                @urban_categories["sort_order"] = @menu_category.sort_order
              end
              @urban_categories["active"] = @menu_category.is_visible
              if @menu_category.menu_category_image.present?
                @urban_categories["img_url"] = "#{@my_site_url}#{@menu_category.menu_category_image}"
              end
              @urban_menu["categories"].push(@urban_categories)
            end
            @urban_menu["flush_items"] = false
            @urban_menu["items"]=[]
            @option_g_arr=[]
            @option_arr=[]
            @option_group_id_arr=[]
            @taxes=[]
            @charges=[]
            @menu_products.each do |mp| # MENU PRODUCT LOOP START
              if mp.mode == 1
                @urban_items={}
                @urban_items["ref_id"] = mp.id.to_s
                @urban_items["title"] = mp.product.name
                _child_mp = MenuProduct.find(mp.id).child_menu_product(_unit_id)
                if _child_mp.present?
                  if _child_mp.sold_at_store
                    @urban_items["sold_at_store"] = true
                    @urban_items["available"] = _child_mp.mode == 1 ? true : false
                  else
                    @urban_items["sold_at_store"] = false
                    @urban_items["available"] = false
                  end
                  @urban_items["price"] = _child_mp.sell_price_without_tax
                  @urban_items["current_stock"] = -1
                else
                  @urban_items["price"] = mp.sell_price_without_tax
                  @urban_items["sold_at_store"] = false
                  @urban_items["available"] = false
                  @urban_items["current_stock"] = -1
                end
                @urban_items["category_ref_ids"] = ["#{mp.menu_category_id.to_s}"]

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
            end # MENU PRODUCT LOOP END
            @menu_card_option_groups = AddonsGroup.set_section(@menu_card.section.id)
            @menu_card_option_groups.each do |mcog| # MENU CARD ADDONS GROUP LOOP
              @option_group_id_arr.push(mcog.id)
              @options_g_hash={}
              @options_g_hash["ref_id"] = mcog.id.to_s
              @options_g_hash["title"] = mcog.title
              @options_g_hash["min_selectable"] = mcog.min_selectable.present? ? mcog.min_selectable.to_i : 0
              @options_g_hash["max_selectable"] = mcog.max_selectable.present? ? mcog.max_selectable.to_i : -1
              @options_g_hash["active"] = true
              @options_g_hash["item_ref_ids"] = []
              @options_g_menu_product = MenuProduct.by_menu_card_and_addons_group(params[:menu_card_id], mcog.id)
              @options_g_menu_product.each do |ogmp|
                if ogmp.mode == 1
                  @options_g_hash["item_ref_ids"].push(ogmp.id.to_s)
                end
              end
              @option_g_arr.push(@options_g_hash)
            end # MENU CARD ADDONS GROUP LOOP END
            @urban_menu["option_groups"]=@option_g_arr
            @addons = AddonsGroupProduct.by_addons_group_id_in(@option_group_id_arr)
            @addons.each do |option| # ADDONS LOOP
              if !@option_arr.any? {|h| h[:ref_id] == option.product.id}
                @option_hash={}
                @option_hash["ref_id"] = option.product.id.to_s
                @option_hash["title"] = option.product.name
                @option_hash["description"] = option.product.short_description.present? ? option.product.short_description : nil
                @option_hash["weight"] = option.ammount
                @option_hash["available"] = true
                if @unit_id.to_i > 0
                  _child_addon = AddonsGroupProduct.by_product_and_punit_and_qnt_and_unit(option.product.id, option.product_unit_id, option.ammount, @unit_id).first
                  if _child_addon.present?
                    @option_hash["price"] = _child_addon.price
                  else
                    @option_hash["price"] = option.price
                  end
                else
                  @option_hash["price"] = option.price
                end
                # @option_hash["price"] = option.price
                @option_hash["sold_at_store"] = true
                @option_hash["opt_grp_ref_ids"] =  []
                # @menu_card_1 = MenuCard.find(params[:menu_card_id])
                AddonsGroup.set_product_master_section(option.product.id,current_user.unit.id,@menu_card.section.id).each do |g|
                  @option_hash["opt_grp_ref_ids"].push(g.id.to_s)
                end
                @option_arr.push(@option_hash)
              end
            end # ADDONS LOOP
            @urban_menu["options"]=@option_arr
            @tax_classes=TaxClass.by_tax_classes(@tax_class_ids)
            @tax_classes.each do |tax_class| # TAX CLASS/CHARGES LOOP
              @tax_class_hash={}
              @charge_hash={}
              if tax_class.tax_type == "simple"
                if tax_class.ammount > 0
                  @tax_class_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
                  @tax_class_hash["title"] = tax_class.name
                  @tax_class_hash["description"] = tax_class.name
                  @tax_class_hash["active"] = true
                  @tax_class_hash["structure"] = {}
                    @tax_class_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                    @tax_class_hash["structure"]["applicable_on"]= "item.price"
                    @tax_class_hash["structure"]["value"]= tax_class.ammount
                  @tax_class_hash["item_ref_ids"]=[]
                  @menu_products.each do |tmp|
                    if tmp.tax_group.tax_classes.include? tax_class
                      if tmp.mode == 1
                        @tax_class_hash["item_ref_ids"].push(tmp.id.to_s)
                      end
                    end
                  end
                  @taxes.push(@tax_class_hash)
                end
              elsif tax_class.tax_type != "veriable" || tax_class.tax_type != "simple"
                @charge_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
                @charge_hash["title"] = tax_class.name
                @charge_hash["description"] = tax_class.name
                @charge_hash["active"] = true
                @charge_hash["structure"] = {}
                  @charge_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                  @charge_hash["structure"]["applicable_on"]= "item.quantity"
                  @charge_hash["structure"]["value"]= tax_class.ammount
                @charge_hash["item_ref_ids"]=[]
                @menu_products.each do |tmp|
                  if tmp.tax_group.tax_classes.include? tax_class
                    if tmp.mode == 1
                      @charge_hash["item_ref_ids"].push(tmp.id.to_s)
                    end
                  end
                end
                @charges.push(@charge_hash)
              end
            end  # TAX CLASS/CHARGES LOOP END
            @urban_menu["taxes"]=@taxes
            @urban_menu["charges"]=@charges
            @urban_menu["callback_url"] = nil # "http://#{@my_site_url}"
            logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON START **************** +"
            logger.debug @urban_menu.to_json
            logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON END **************** +"
            
            @response=ThirdpartyUrbanpiper.thirdparty_urbanpiper_cat_item_upload(@thirdparty_dtl,@urban_menu.to_json,_unit_id)
            logger.debug "+ ******************** URBANPIPER RESPONSE START **************** +"
            logger.debug @response
            logger.debug "+ ******************** URBANPIPER RESPONSE END **************** +"
            if JSON.parse(@response)["status"] == "success"
              if _unit_id.to_i > 0
                @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}" }
                @message_arr.push(@message_hash)
                sleep 7
              else
                @message_hash = {"status" => true, "message" => "Owner master menu." }
                @message_arr.push(@message_hash)
              end
            else
              if _unit_id.to_i > 0
                @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}" }
                @message_arr.push(@message_hash)
                sleep 7
              else
                @message_hash = {"status" => false, "message" => "Owner master menu." }
                @message_arr.push(@message_hash)
              end
            end
          end # UNIT LOOP END
        end
      else # UNIT NOT SELECTED
        _unit_id = -1
        if params[:up_item_id].present? && JSON.parse(params[:up_item_id]).count > 0 # ITEM SELECED
          @menu_products = @menu_card.menu_products.not_deleted
          _p_ids =[]
          if params[:up_item_id].present? && JSON.parse(params[:up_item_id]).count > 0
            JSON.parse(params[:up_item_id]).each do |i|
              _p_ids.push(i)
            end
            @menu_products = MenuProduct.set_menu_product_in(_p_ids)
          end
          @tax_class_ids = []
          @menu_products.each do |po|
            po.tax_group.tax_classes.each do |tc|
              if !(@tax_class_ids.include? tc.id)
                @tax_class_ids.push(tc.id)
              end
            end
          end
          @menu_product_ids = @menu_products.map { |e| e.id } 
          @unique_munu_cat_p = @menu_products.select('distinct on (menu_category_id) *')   # TO GET UNIQUE MENU CATEGORY ID
          @unique_munu_cat = []
          @unique_munu_cat_p.each do |m_cat_id|
            @unique_munu_cat.push(m_cat_id.menu_category_id)
          end
          @unique_parent_menu_cat = []
          @unique_munu_cat.each do |ucid|
            @menu_c_category = MenuCategory.find(ucid)
            if @menu_c_category.parent.present? && @menu_c_category.is_parent_visible.present?
              if !(@unique_parent_menu_cat.include? @menu_c_category.parent)
                if @menu_c_category.is_parent_visible
                  @unique_parent_menu_cat.push(@menu_c_category.parent)
                end
              end
            end
          end
          @unique_munu_cat = @unique_munu_cat + @unique_parent_menu_cat
          @urban_menu={}
          @urban_menu["categories"]=[]
          @unique_munu_cat.each do |umc| 
            @menu_category = MenuCategory.find(umc)
            @urban_categories={}
            @urban_categories["ref_id"] = @menu_category.id.to_s
            if @menu_category.parent.present?
              if @menu_category.is_parent_visible == true
                @urban_categories["parent_ref_id"] = @menu_category.parent.to_s
              end
            end
            @urban_categories["name"] = @menu_category.name
            if @menu_category.description.present?
              @urban_categories["description"] = @menu_category.description
            end
            if @menu_category.sort_order.present?
              @urban_categories["sort_order"] = @menu_category.sort_order
            end
            @urban_categories["active"] = @menu_category.is_visible
            if @menu_category.menu_category_image.present?
              @urban_categories["img_url"] = "#{@my_site_url}#{@menu_category.menu_category_image}"
            end
            @urban_menu["categories"].push(@urban_categories)
          end
          @urban_menu["flush_items"] = false
          @urban_menu["items"]=[]
          @option_g_arr=[]
          @option_arr=[]
          @option_group_id_arr=[]
          @taxes=[]
          @charges=[]
          @menu_products.each do |mp| # MENU PRODUCT LOOP START
            if mp.mode == 1
              @urban_items={}
              @urban_items["ref_id"] = mp.id.to_s
              @urban_items["title"] = mp.product.name
              @urban_items["available"] = true
              @urban_items["price"] = mp.sell_price_without_tax
              if @thirdparty_dtl.is_product_desc.present?
                if @thirdparty_dtl.is_product_desc == "1"
                  if mp.product.short_description.present?
                    @urban_items["description"] = mp.product.short_description
                  end
                end
              end
              @urban_items["current_stock"] = -1
              if mp.product.product_religion.present? && mp.product.product_religion.name.downcase == "vegetarian"
                @urban_items["food_type"] = "1"
              elsif mp.product.product_religion.present? && mp.product.product_religion.name.downcase == "non-vegetarian"
                @urban_items["food_type"] = "2"
              elsif mp.product.product_religion.present? && mp.product.product_religion.name.downcase == "eggetarian"
                @urban_items["food_type"] = "3"
              else
                @urban_items["food_type"] = "4"
              end
              _image = mp.product.product_images.first
              _image_url = _image.present? ? "http://#{@my_site_url}#{_image.image.url(:"original")}" : ""

              if @thirdparty_dtl.is_product_image.present?
                if @thirdparty_dtl.is_product_image == "1"
                  @urban_items["img_url"] = _image_url
                end
              end
              @urban_items["category_ref_ids"] = ["#{mp.menu_category_id.to_s}"]

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
            end # ACTIVE MENU PRODUCT END
          end # MENU PRODUCT LOOP END
          @menu_card_option_groups = AddonsGroup.set_section(@menu_card.section.id)
          @menu_card_option_groups.each do |mcog| # MENU CARD ADDONS GROUP LOOP
            @option_group_id_arr.push(mcog.id)
            @options_g_hash={}
            @options_g_hash["ref_id"] = mcog.id.to_s
            @options_g_hash["title"] = mcog.title
            @options_g_hash["min_selectable"] = mcog.min_selectable.present? ? mcog.min_selectable.to_i : 0
            @options_g_hash["max_selectable"] = mcog.max_selectable.present? ? mcog.max_selectable.to_i : -1
            @options_g_hash["active"] = true
            @options_g_hash["item_ref_ids"] = []
            @options_g_menu_product = MenuProduct.by_menu_card_and_addons_group(params[:menu_card_id], mcog.id)
            @options_g_menu_product.each do |ogmp|
              if ogmp.mode == 1 && JSON.parse(params[:up_item_id]).include?(ogmp.id.to_s)
                @options_g_hash["item_ref_ids"].push(ogmp.id.to_s)
              end
            end
            @option_g_arr.push(@options_g_hash)
          end # MENU CARD ADDONS GROUP LOOP END
          @urban_menu["option_groups"]=@option_g_arr
          @addons = AddonsGroupProduct.by_addons_group_id_in(@option_group_id_arr)
          @addons.each do |option| # ADDONS LOOP
            if !@option_arr.any? {|h| h[:ref_id] == option.product.id}
              @option_hash={}
              @option_hash["ref_id"] = option.product.id.to_s
              @option_hash["title"] = option.product.name
              if option.product.short_description.present?
                @option_hash["description"] = option.product.short_description
              end
              @option_hash["weight"] = option.ammount
              @option_hash["available"] = true
              if @unit_id.to_i > 0
                _child_addon = AddonsGroupProduct.by_product_and_punit_and_qnt_and_unit(option.product.id, option.product_unit_id, option.ammount, @unit_id).first
                if _child_addon.present?
                  @option_hash["price"] = _child_addon.price
                else
                  @option_hash["price"] = option.price
                end
              else
                @option_hash["price"] = option.price
              end
              # @option_hash["price"] = option.price
              @option_hash["sold_at_store"] = true
              @option_hash["opt_grp_ref_ids"] =  []
              # @menu_card_1 = MenuCard.find(params[:menu_card_id])
              AddonsGroup.set_product_master_section(option.product.id,current_user.unit.id,@menu_card.section.id).each do |g|
                @option_hash["opt_grp_ref_ids"].push(g.id.to_s)
              end
              @option_arr.push(@option_hash)
            end
          end # ADDONS LOOP
          @urban_menu["options"]=@option_arr
          @tax_classes=TaxClass.by_tax_classes(@tax_class_ids)
          @tax_classes.each do |tax_class| # TAX CLASS/CHARGES LOOP
            @tax_class_hash={}
            @charge_hash={}
            if tax_class.tax_type == "simple"
              if tax_class.ammount > 0
                @tax_class_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
                @tax_class_hash["title"] = tax_class.name
                @tax_class_hash["description"] = tax_class.name
                @tax_class_hash["active"] = true
                @tax_class_hash["structure"] = {}
                  @tax_class_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                  @tax_class_hash["structure"]["applicable_on"]= "item.price"
                  @tax_class_hash["structure"]["value"]= tax_class.ammount
                @tax_class_hash["item_ref_ids"]=[]
                @menu_products.each do |tmp|
                  if tmp.tax_group.tax_classes.include? tax_class
                    if tmp.mode == 1 && JSON.parse(params[:up_item_id]).include?(tmp.id.to_s)
                      @tax_class_hash["item_ref_ids"].push(tmp.id.to_s)
                    end
                  end
                end
                @taxes.push(@tax_class_hash)
              end
            elsif tax_class.tax_type != "veriable" || tax_class.tax_type != "simple"
              @charge_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
              @charge_hash["title"] = tax_class.name
              @charge_hash["description"] = tax_class.name
              @charge_hash["active"] = true
              @charge_hash["structure"] = {}
                @charge_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                @charge_hash["structure"]["applicable_on"]= "item.quantity"
                @charge_hash["structure"]["value"]= tax_class.ammount
              @charge_hash["item_ref_ids"]=[]
              @menu_products.each do |tmp|
                if tmp.tax_group.tax_classes.include? tax_class
                  if tmp.mode == 1 && JSON.parse(params[:up_item_id]).include?(tmp.id.to_s)
                    @charge_hash["item_ref_ids"].push(tmp.id.to_s)
                  end
                end
              end
              @charges.push(@charge_hash)
            end
          end  # TAX CLASS/CHARGES LOOP END
          @urban_menu["taxes"]=@taxes
          @urban_menu["charges"]=@charges
          @urban_menu["callback_url"] = nil # "http://#{@my_site_url}"
          logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON START **************** +"
          logger.debug @urban_menu.to_json
          logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON END **************** +"
          
          @response=ThirdpartyUrbanpiper.thirdparty_urbanpiper_cat_item_upload(@thirdparty_dtl,@urban_menu.to_json,_unit_id)
          logger.debug "+ ******************** URBANPIPER RESPONSE START **************** +"
          logger.debug @response
          logger.debug "+ ******************** URBANPIPER RESPONSE END **************** +"
          if JSON.parse(@response)["status"] == "success" 
            @message_hash = {"status" => true, "message" => "Owner master menu." }
            @message_arr.push(@message_hash)  
          else
            @message_hash = {"status" => false, "message" => "Owner master menu." }
            @message_arr.push(@message_hash)
          end
        else # ITEM NOT SELECED 
          @menu_products = @menu_card.menu_products.not_deleted
          if @menu_card.sort_items_by.present?
            @menu_products = @menu_products.order("#{@menu_card.sort_items_by} #{@menu_card.sort_order}")
          end
          @tax_class_ids = []
          @menu_products.each do |po|
            po.tax_group.tax_classes.each do |tc|
              if !(@tax_class_ids.include? tc.id)
                @tax_class_ids.push(tc.id)
              end
            end
          end
          @menu_product_ids = @menu_products.map { |e| e.id } 
          @unique_munu_cat_p = @menu_card.menu_products.select('distinct on (menu_category_id) *')   # TO GET UNIQUE MENU CATEGORY ID
          @unique_munu_cat = []
          @unique_munu_cat_p.each do |m_cat_id|
            @unique_munu_cat.push(m_cat_id.menu_category_id)
          end
          @unique_parent_menu_cat = []
          @unique_munu_cat.each do |ucid|
            @menu_c_category = MenuCategory.find(ucid)
            if @menu_c_category.parent.present? && @menu_c_category.is_parent_visible.present?
              if !(@unique_parent_menu_cat.include? @menu_c_category.parent)
                if @menu_c_category.is_parent_visible
                  @unique_parent_menu_cat.push(@menu_c_category.parent)
                end
              end
            end
          end
          @unique_munu_cat = @unique_munu_cat + @unique_parent_menu_cat
          @urban_menu={}
          @urban_menu["categories"]=[]
          @unique_munu_cat.each do |umc| 
            @menu_category = MenuCategory.find(umc)
            @urban_categories={}
            @urban_categories["ref_id"] = @menu_category.id.to_s
            if @menu_category.parent.present?
              if @menu_category.is_parent_visible == true
                @urban_categories["parent_ref_id"] = @menu_category.parent.to_s
              end
            end
            @urban_categories["name"] = @menu_category.name
            if @menu_category.description.present?
              @urban_categories["description"] = @menu_category.description
            end
            if @menu_category.sort_order.present?
              @urban_categories["sort_order"] = @menu_category.sort_order
            end
            @urban_categories["active"] = @menu_category.is_visible
            if @menu_category.menu_category_image.present?
              @urban_categories["img_url"] = "#{@my_site_url}#{@menu_category.menu_category_image}"
            end
            @urban_menu["categories"].push(@urban_categories)
          end
          @urban_menu["flush_items"] = true
          @urban_menu["items"]=[]
          @option_g_arr=[]
          @option_arr=[]
          @option_group_id_arr=[]
          @taxes=[]
          @charges=[]
          @cat_item_count = 1
          @menu_products.each do |mp| # MENU PRODUCT LOOP START
            if mp.mode == 1
              @urban_items={}
              @urban_items["ref_id"] = mp.id.to_s
              @urban_items["title"] = mp.product.name
              if @menu_card.sort_items_by.present? 
                @urban_items["sort_order"] = @cat_item_count
              end
              @urban_items["available"] = true
              @urban_items["price"] = mp.sell_price_without_tax
              
              if @thirdparty_dtl.is_product_desc.present?
                if @thirdparty_dtl.is_product_desc == "1"
                  if mp.product.short_description.present?
                    @urban_items["description"] = mp.product.short_description
                  end
                end
              end
              @urban_items["current_stock"] = -1
              if mp.product.product_religion.present? && mp.product.product_religion.name.downcase == "vegetarian"
                @urban_items["food_type"] = "1"
              elsif mp.product.product_religion.present? && mp.product.product_religion.name.downcase == "non-vegetarian"
                @urban_items["food_type"] = "2"
              elsif mp.product.product_religion.present? && mp.product.product_religion.name.downcase == "eggetarian"
                @urban_items["food_type"] = "3"
              else
                @urban_items["food_type"] = "4"
              end
              _image = mp.product.product_images.first
              _image_url = _image.present? ? "http://#{@my_site_url}#{_image.image.url(:"original")}" : ""

              if @thirdparty_dtl.is_product_image.present?
                if @thirdparty_dtl.is_product_image == "1"
                  @urban_items["img_url"] = _image_url
                end
              end
              @urban_items["category_ref_ids"] = ["#{mp.menu_category_id.to_s}"]

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
              @cat_item_count = @cat_item_count+1
              @urban_menu["items"].push(@urban_items)
            end # ACTIVE MENU PRODUCT END
          end # MENU PRODUCT LOOP END
          @menu_card_option_groups = AddonsGroup.set_section(@menu_card.section.id)
          @menu_card_option_groups.each do |mcog| # MENU CARD ADDONS GROUP LOOP
            @option_group_id_arr.push(mcog.id)
            @options_g_hash={}
            @options_g_hash["ref_id"] = mcog.id.to_s
            @options_g_hash["title"] = mcog.title
            @options_g_hash["min_selectable"] = mcog.min_selectable.present? ? mcog.min_selectable.to_i : 0
            @options_g_hash["max_selectable"] = mcog.max_selectable.present? ? mcog.max_selectable.to_i : -1
            @options_g_hash["active"] = true
            @options_g_hash["item_ref_ids"] = []
            @options_g_menu_product = MenuProduct.by_menu_card_and_addons_group(params[:menu_card_id], mcog.id)
            @options_g_menu_product.each do |ogmp|
              if ogmp.mode == 1
                @options_g_hash["item_ref_ids"].push(ogmp.id.to_s)
              end
            end
            @option_g_arr.push(@options_g_hash)
          end # MENU CARD ADDONS GROUP LOOP END
          @urban_menu["option_groups"]=@option_g_arr
          @addons = AddonsGroupProduct.by_addons_group_id_in(@option_group_id_arr)
          @addons.each do |option| # ADDONS LOOP
            if !@option_arr.any? {|h| h[:ref_id] == option.product.id}
              @option_hash={}
              @option_hash["ref_id"] = option.product.id.to_s
              @option_hash["title"] = option.product.name
              @option_hash["description"] = option.product.short_description.present? ? option.product.short_description : nil
              @option_hash["weight"] = option.ammount
              @option_hash["available"] = true
              if @unit_id.to_i > 0
                _child_addon = AddonsGroupProduct.by_product_and_punit_and_qnt_and_unit(option.product.id, option.product_unit_id, option.ammount, @unit_id).first
                if _child_addon.present?
                  @option_hash["price"] = _child_addon.price
                else
                  @option_hash["price"] = option.price
                end
              else
                @option_hash["price"] = option.price
              end
              # @option_hash["price"] = option.price
              @option_hash["sold_at_store"] = true
              @option_hash["opt_grp_ref_ids"] =  []
              # @menu_card_1 = MenuCard.find(params[:menu_card_id])
              AddonsGroup.set_product_master_section(option.product.id,current_user.unit.id,@menu_card.section.id).each do |g|
                @option_hash["opt_grp_ref_ids"].push(g.id.to_s)
              end
              @option_arr.push(@option_hash)
            end
          end # ADDONS LOOP
          @urban_menu["options"]=@option_arr
          @tax_classes=TaxClass.by_tax_classes(@tax_class_ids)
          @tax_classes.each do |tax_class| # TAX CLASS/CHARGES LOOP
            @tax_class_hash={}
            @charge_hash={}
            if tax_class.tax_type == "simple"
              if tax_class.ammount > 0
                @tax_class_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
                @tax_class_hash["title"] = tax_class.name
                @tax_class_hash["description"] = tax_class.name
                @tax_class_hash["active"] = true
                @tax_class_hash["structure"] = {}
                  @tax_class_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                  @tax_class_hash["structure"]["applicable_on"]= "item.price"
                  @tax_class_hash["structure"]["value"]= tax_class.ammount
                @tax_class_hash["item_ref_ids"]=[]
                @menu_products.each do |tmp|
                  if tmp.tax_group.tax_classes.include? tax_class
                    if tmp.mode == 1
                      @tax_class_hash["item_ref_ids"].push(tmp.id.to_s)
                    end
                  end
                end
                @taxes.push(@tax_class_hash)
              end
            elsif tax_class.tax_type != "veriable" || tax_class.tax_type != "simple"
              @charge_hash["ref_id"] = _unit_id == -1 ? tax_class.id.to_s : "#{_unit_id}-#{tax_class.id}"
              @charge_hash["title"] = tax_class.name
              @charge_hash["description"] = tax_class.name
              @charge_hash["active"] = true
              @charge_hash["structure"] = {}
                @charge_hash["structure"]["type"]= tax_class.amount_type == "percentage" ? "percentage" : "fixed"
                @charge_hash["structure"]["applicable_on"]= "item.quantity"
                @charge_hash["structure"]["value"]= tax_class.ammount
              @charge_hash["item_ref_ids"]=[]
              @menu_products.each do |tmp|
                if tmp.tax_group.tax_classes.include? tax_class
                  if tmp.mode == 1
                    @charge_hash["item_ref_ids"].push(tmp.id.to_s)
                  end
                end
              end
              @charges.push(@charge_hash)
            end
          end  # TAX CLASS/CHARGES LOOP END
          @urban_menu["taxes"]=@taxes
          @urban_menu["charges"]=@charges
          @urban_menu["callback_url"] = nil # "http://#{@my_site_url}"
          logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON START **************** +"
          logger.debug @urban_menu.to_json
          logger.debug "+ ******************** URBANPIPER UPLOADED MENU JSON END **************** +"
          
          @response=ThirdpartyUrbanpiper.thirdparty_urbanpiper_cat_item_upload(@thirdparty_dtl,@urban_menu.to_json,_unit_id)
          logger.debug "+ ******************** URBANPIPER RESPONSE START **************** +"
          logger.debug @response
          logger.debug "+ ******************** URBANPIPER RESPONSE END **************** +"
          if JSON.parse(@response)["status"] == "success"
            @message_hash = {"status" => true, "message" => "Owner master menu." }
            @message_arr.push(@message_hash)
          else
            @message_hash = {"status" => false, "message" => "Owner master menu." }
            @message_arr.push(@message_hash)
          end
        end # ITEM NOT SELECTED END
      end # UNIT NOT SELECTED END
    end  # URBANPIPER END HERE
    # MIGRATION CODE END HERE

    if @thirdparty_dtl.thirdparty == "zomato"  # START ZOMATO
      @zomato_menu={}
      @zomato_menu["outlet_id"] = params[:unit_id]
      @zomato_menu["menu"] = {}
      @zomato_menu["menu"]["taxes"] = []
      @zomato_menu["menu"]["charges"] = []
      _unique_tax_calss_ids=[]
      @menu_card.menu_products.each do |mp|
        mp.tax_group.tax_classes.each do |tc|
          if !_unique_tax_calss_ids.include?(tc.id)
            _unique_tax_calss_ids.push(tc.id)
          end
        end
      end
      _unique_tax_calss_ids.each do |tcc|
        _tax_class=TaxClass.find(tcc)
        if _tax_class.tax_type == "simple" 
          if _tax_class.ammount > 0
            @tax_class_hash = {}
            @tax_class_hash["tax_id"] = _tax_class.id
            @tax_class_hash["tax_name"] = _tax_class.name
            @tax_class_hash["tax_type"] = _tax_class.amount_type == "percentage" ? "PERCENTAGE" : "FIXED"
            @tax_class_hash["tax_value"] = _tax_class.ammount
            @tax_class_hash["tax_is_active"] = _tax_class.is_trashed == false ? 1 : 0
            @zomato_menu["menu"]["taxes"].push(@tax_class_hash)
          end
        else
          if _tax_class.ammount > 0
            @tax_charge_hash = {}
            @tax_charge_hash["charge_id"] = _tax_class.id
            @tax_charge_hash["charge_name"] = _tax_class.name
            @tax_charge_hash["charge_type"] = _tax_class.amount_type == "percentage" ? "PERCENTAGE" : "FIXED"
            @tax_charge_hash["charge_value"] = _tax_class.ammount
            @tax_charge_hash["charge_is_active"] = _tax_class.is_trashed == false ? 1 : 0
            @tax_charge_hash["applicable_on"] = "ITEM"
            @tax_charge_hash["charge_always_applicable"] = _tax_class.tax_type == "variable" ? 0 : 1
            @tax_charge_hash["charge_applicable_below_order_amount"] = _tax_class.upper_limit
            @tax_charge_hash["has_tier_wise_values"] = 0
            @zomato_menu["menu"]["charges"].push(@tax_charge_hash)
          end
        end
      end
      @zomato_menu["menu"]["categories"]=[]
      @category_ids = []
      @unique_munu_cat.each do |umc| 
        if MenuCategory.find(umc).parent.present?
          @category_ids.push(MenuCategory.find(umc).parent)
        else
          @category_ids.push(umc)
        end
      end
      @category_ids.uniq.each do |cid|
        @category_hash={}
        @category = MenuCategory.find(cid)
        @category_hash["category_id"] = @category.id
        @category_hash["category_name"] = @category.name
        @category_hash["category_description"] = ""
        @category_hash["category_is_active"] = 1
        @category_hash["category_image_url"] = ""
        @category_hash["category_schedules"] = [{:schedule_name => "All Day Menu", :schedule_day => [1,2,3,4,5,6,7],:schedule_time_slots => [{:start_time=> "08:00:00", :end_time => "23:00:00"}]}]
        @category_hash["has_subcategory"] = 1
        @category_hash["subcategories"] = []
        @subcategories=MenuCategory.set_parent_category(@category.id)
        @subcategories.each do |scat|
          @subcategory_hash={}
          @subcategory_hash["subcategory_id"] = scat.id
          @subcategory_hash["subcategory_name"] = scat.name
          @subcategory_hash["subcategory_description"] = ""
          @subcategory_hash["subcategory_is_active"] = 1
          @subcategory_hash["subcategory_image_url"] = ""
          @subcategory_hash["items"] = []
          @products=MenuProduct.by_menu_card_and_category(params[:menu_card_id],scat.id)
          @products.each do |pro|
            @product_hash={}
            @product_hash["item_id"] = pro.id
            @product_hash["item_name"] = pro.product.name
            @product_hash["item_unit_price"] = pro.sell_price_without_tax
            @product_hash["item_final_price"] = pro.sell_price_without_tax
            @product_hash["item_short_description"] = pro.product.local_name.present? ? pro.product.local_name : ""
            @product_hash["item_long_description"] = pro.product.local_name.present? ? pro.product.local_name : ""
            @product_hash["item_is_active"] = 1
            @product_hash["item_in_stock"] = pro.stock_qty.to_i > 0 ? 1 : 0
            @product_hash["item_is_default"] = pro.isdefault.present? ? pro.isdefault : 0
            @product_hash["item_image_url"] = ""
            @pro_resturent_offer = pro.sale_rules.first
            if @pro_resturent_offer.present?
              @product_hash["dish_discount"] = {}
              @product_hash["dish_discount"]["discount_type"] = @pro_resturent_offer.sale_rule_output.sale_rule_output_type == "by_percentage" ? "percentage" : "amount"
              @product_hash["dish_discount"]["discount_value"] = @pro_resturent_offer.sale_rule_output.amount
            end
            @product_hash["item_tags"] = []
            if pro.product.product_type == 'variable' 
              @product_hash["groups"] = []
              @product_group_hash = {}
              @product_group_hash["group_id"] = pro.id
              @product_group_hash["group_name"] = pro.product.name
              @product_group_hash["group_description"] = pro.product.local_name.present? ? pro.product.local_name : ""
              @product_group_hash["group_minimum"] = 1
              @product_group_hash["group_maximum"] = 1
              @product_group_hash["group_is_active"] = 1
              @product_group_hash["items"] = []
              @cproducts=Product.products_by_parent(pro.product.id)
              @cproducts.each do |cp|
                @cmp = MenuProduct.find_by_product_id_and_menu_card_id(cp.id,@menu_card.id)
                @group_item_hash={}
                @group_item_hash["item_id"] = @cmp.id
                @group_item_hash["item_name"] = @cmp.product.name
                @group_item_hash["item_unit_price"] = @cmp.sell_price_without_tax
                @group_item_hash["item_final_price"] = @cmp.sell_price_without_tax
                @group_item_hash["item_short_description"] = @cmp.product.local_name.present? ? @cmp.product.local_name : ""
                @group_item_hash["item_long_description"] = @cmp.product.local_name.present? ? @cmp.product.local_name : ""
                @group_item_hash["item_is_active"] = 1
                @group_item_hash["item_in_stock"] = pro.stock_qty.to_i > 0 ? 1 : 0
                @group_item_hash["item_is_default"] = @cmp.isdefault.present? ? @cmp.isdefault : 0
                @group_item_hash["item_image_url"] = ""
                @group_item_hash["item_taxes"] = []
                @group_item_hash["item_charges"] = []
                _gitem_tax_hash = {}
                _gitem_charge_hash = {}
                _gitem_tax_arr =[]
                _gitem_charge_arr=[]
                @cmp.tax_group.tax_classes.each do |tx|
                  if tx.tax_type == "simple"
                    _gitem_tax_arr.push(tx.id)
                  else
                    _gitem_charge_arr.push(tx.id)
                  end
                end
                _gitem_tax_hash["order_type"] = "DELIVERY"
                _gitem_tax_hash["taxes"] = _gitem_tax_arr
                @group_item_hash["item_taxes"].push(_gitem_tax_hash)
                _gitem_charge_hash["order_type"] = "DELIVERY"
                _gitem_charge_hash["charges"] = _gitem_charge_arr
                @group_item_hash["item_charges"].push(_gitem_charge_hash)
                @product_group_hash["items"].push(@group_item_hash)
              end
              @product_hash["groups"].push(@product_group_hash)
            end
                                                # ITEM TAXES AND CHARGES START
            @product_hash["item_taxes"] = []
            @product_hash["item_charges"] = []
            _item_tax_hash = {}
            _item_charge_hash = {}
            _item_tax_arr =[]
            _item_charge_arr=[]
            pro.tax_group.tax_classes.each do |tx|
              if tx.tax_type == "simple"
                if tx.ammount > 0
                  _item_tax_arr.push(tx.id)
                end
              else
                if tx.ammount > 0
                  _item_charge_arr.push(tx.id)
                end
              end
            end
            _item_tax_hash["order_type"] = "DELIVERY"
            _item_tax_hash["taxes"] = _item_tax_arr
            @product_hash["item_taxes"].push(_item_tax_hash)
            _item_charge_hash["order_type"] = "DELIVERY"
            _item_charge_hash["charges"] = _item_charge_arr
            @product_hash["item_charges"].push(_item_charge_hash)

                                              # ITEM TAXES AND CHARGES END

            @product_hash["item_discounts"] =  []

            @subcategory_hash["items"].push(@product_hash)
          end
          @category_hash["subcategories"].push(@subcategory_hash)
        end
        @zomato_menu["menu"]["categories"].push(@category_hash)
      end
      @zomato_menu["restaurant_offers"] = []
      @all_sale_rule = SaleRule.active
      if @all_sale_rule.present? && @all_sale_rule.count > 0
        @all_sale_rule.each do |sl|
          @restaurant_offer_hash = {}
          @restaurant_offer_hash["offer_id"] = sl.id
          @restaurant_offer_hash["start_date"] = sl.valid_from
          @restaurant_offer_hash["end_date"] = sl.valid_till
          @restaurant_offer_hash["timings"] = []
          @r_time = {}
          @r_time["start_time"] = "08:00:00"
          @r_time["end_time"] = "23:00:00"
          @restaurant_offer_hash["timings"].push(@r_time)
          @restaurant_offer_hash["offer_type"] =  "DISH"
          @restaurant_offer_hash["min_order_amount"] = 0
          @restaurant_offer_hash["first_order_only"] = 0
          @restaurant_offer_hash["is_active"] = 1
          @restaurant_offer_hash["discount_title"] = sl.name
          @zomato_menu["restaurant_offers"].push(@restaurant_offer_hash)
        end
      end

      puts @zomato_menu.to_json
      @menu_uploaded=ThirdpartyZomato.thirdparty_zomato_menu_upload(@zomato_menu.to_json)
      # if params[:thirdparty_operation].present? && params[:thirdparty_operation]=="upload"
      #   @menu_uploaded=ThirdpartyZomato.thirdparty_zomato_menu_upload(@zomato_menu.to_json)
      # elsif params[:thirdparty_operation].present? && params[:thirdparty_operation]=="update"
      #   @menu_uploaded=ThirdpartyZomato.thirdparty_zomato_menu_update(@zomato_menu.to_json)
      # end

      if @menu_uploaded == true
        @message_hash = {"status" => true, "message" => "Menu categories and items was successfully submited to zomato." }
        @message_arr.push(@message_hash)
        # redirect_to :back, notice: 'Menu categories and items was successfully submited to zomato.'
      else
        @message_hash = {"status" => false, "message" => "Failed to submit to zomato." }
        @message_arr.push(@message_hash)
        # redirect_to :back, alert: 'Failed to submit to zomato.'
      end
    end # END ZOMATO

    _secc_msg = "<b>Success For :</b>"
    _err_msg = "<font color='red'><b>Failed For :</font></b>"
    @message_arr.each do |_msg|
      _secc_msg = "#{_secc_msg} <br>#{_msg["message"]}." if _msg["status"] == true
      _err_msg = "#{_err_msg} <br><font color='red'>#{_msg["message"]}.</font>" if _msg["status"] == false
    end
    redirect_to :back, notice: "#{_secc_msg}<br>#{_err_msg}".html_safe
  end

  def thirdparty_menu_toggle
    @thirdparty_dtl = ThirdpartyConfiguration.find(params[:thirdparty_configuration_id])
    if params[:unit_id].present?
      @message_arr = []
      params[:unit_id].each do |_unit_id|
        @toggle_hash_enable = {}
        @toggle_hash_disable = {}
        @toggle_hash_enable["location_ref_id"] = _unit_id.to_s
        @toggle_hash_disable["location_ref_id"] = _unit_id.to_s
        @toggle_hash_enable["item_ref_ids"] = []
        @toggle_hash_disable["item_ref_ids"] = []
        _menu_card_products = MenuProduct.by_menu_card(params[:toggle_menu_card_id])
        if _menu_card_products.present?
          _menu_card_products.each do |i|
            _child_mp = MenuProduct.find(i.id).child_menu_product(_unit_id)
            if _child_mp.present? && params[:thirdparty_action].present?
              if _child_mp.sold_at_store
                if _child_mp.mode == 1
                  @toggle_hash_enable["item_ref_ids"].push(i.id.to_s)
                  @toggle_hash_enable["action"] = "enable"
                else
                  @toggle_hash_disable["item_ref_ids"].push(i.id.to_s)
                  @toggle_hash_disable["action"] = "disable"
                end
              end
            else
              @toggle_hash_disable["item_ref_ids"].push(i.id.to_s)
              @toggle_hash_disable["action"] = "disable"
            end
          end

          # @toggle_hash_temp["action"] = params[:toggle_thirdparty_item_action].present? ? "enable" : "disable"
          if @toggle_hash_enable["item_ref_ids"].count > 0
            @menu_toggled=ThirdpartyUrbanpiper.thirdparty_urbanpiper_channel_toggle(@thirdparty_dtl,@toggle_hash_enable.to_json)
            if @menu_toggled == true
              @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "enable" }
              @message_arr.push(@message_hash)
            else
              @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "enable" }
              @message_arr.push(@message_hash)
            end
          end
          sleep 5
          if @toggle_hash_disable["item_ref_ids"].count > 0
            @menu_toggled=ThirdpartyUrbanpiper.thirdparty_urbanpiper_channel_toggle(@thirdparty_dtl,@toggle_hash_disable.to_json)
            if @menu_toggled == true
              @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "disable" }
              @message_arr.push(@message_hash)
            else
              @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "disable" }
              @message_arr.push(@message_hash)
            end
          end
          sleep 5
        end
      end
      _enable_message = "<b>Enable:</b><br>"
      _disable_message = "<b>Disable:</b><br>"
      @message_arr.each do |_msg|
        _enable_message = "#{_enable_message} For #{_msg["message"]}, Done successfully.<br>" if _msg["status"] == true && _msg["process"] == "enable"
        _enable_message = "#{_enable_message} <font color='red'>For #{_msg["message"]}, Failed.</font><br>" if _msg["status"] == false && _msg["process"] == "enable"
        _disable_message = "#{_disable_message} For #{_msg["message"]}, Done successfully.<br>" if _msg["status"] == true && _msg["process"] == "disable"
        _disable_message = "#{_disable_message} <font color='red'>For #{_msg["message"]}, Failed.</font><br>" if _msg["status"] == false && _msg["process"] == "disable"
      end
      redirect_to :back, notice: "#{_enable_message}<br>#{_disable_message}".html_safe
    else
      redirect_to :back, alert: "Please, Select at list one outlet."
    end
  end

  def urbanpiper_item_toggle
    @thirdparty_dtl = ThirdpartyConfiguration.find(params[:thirdparty_configuration_id])
    if params[:unit_id].present?
      @message_arr = []
      params[:unit_id].each do |_unit_id|
        @toggle_hash_enable = {}
        @toggle_hash_disable = {}
        @toggle_hash_enable["location_ref_id"] = _unit_id.to_s
        @toggle_hash_disable["location_ref_id"] = _unit_id.to_s
        @toggle_hash_enable["item_ref_ids"] = []
        @toggle_hash_disable["item_ref_ids"] = []
        JSON.parse(params[:toggle_item_id]).each do |i|
          _child_mp = MenuProduct.find(i).child_menu_product(_unit_id)
          if _child_mp.present?
            if _child_mp.sold_at_store
              if _child_mp.mode == 1
                @toggle_hash_enable["item_ref_ids"].push(i.to_s)
                @toggle_hash_enable["action"] = "enable"
              else
                @toggle_hash_disable["item_ref_ids"].push(i.to_s)
                @toggle_hash_disable["action"] = "disable"
              end
            end
          else
            @toggle_hash_disable["item_ref_ids"].push(i.to_s)
            @toggle_hash_disable["action"] = "disable"
          end
        end

        # @toggle_hash_temp["action"] = params[:toggle_thirdparty_item_action].present? ? "enable" : "disable"
        if @toggle_hash_enable["item_ref_ids"].count > 0
          @menu_toggled=ThirdpartyUrbanpiper.thirdparty_urbanpiper_channel_toggle(@thirdparty_dtl,@toggle_hash_enable.to_json)
          if @menu_toggled == true
            @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "enable" }
            @message_arr.push(@message_hash)
          else
            @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "enable" }
            @message_arr.push(@message_hash)
          end
        end
        sleep 5
        if @toggle_hash_disable["item_ref_ids"].count > 0
          @menu_toggled=ThirdpartyUrbanpiper.thirdparty_urbanpiper_channel_toggle(@thirdparty_dtl,@toggle_hash_disable.to_json)
          if @menu_toggled == true
            @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "disable" }
            @message_arr.push(@message_hash)
          else
            @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "disable" }
            @message_arr.push(@message_hash)
          end
        end
        sleep 5
      end
      _enable_message = "<b>Enable:</b><br>"
      _disable_message = "<b>Disable:</b><br>"
      @message_arr.each do |_msg|
        _enable_message = "#{_enable_message} For #{_msg["message"]}, Done successfully.<br>" if _msg["status"] == true && _msg["process"] == "enable"
        _enable_message = "#{_enable_message} <font color='red'>For #{_msg["message"]}, Failed.</font><br>" if _msg["status"] == false && _msg["process"] == "enable"
        _disable_message = "#{_disable_message} For #{_msg["message"]}, Done successfully.<br>" if _msg["status"] == true && _msg["process"] == "disable"
        _disable_message = "#{_disable_message} <font color='red'>For #{_msg["message"]}, Failed.</font><br>" if _msg["status"] == false && _msg["process"] == "disable"
      end
      redirect_to :back, notice: "#{_enable_message}<br>#{_disable_message}".html_safe
    else
      redirect_to :back, alert: "Please, Select at list one outlet."
    end
  end

  def urbanpiper_item_toggle_outlet
    @thirdparty_dtl = ThirdpartyConfiguration.find(params[:thirdparty_configuration_id])
    @message_arr = []
    _unit_id = params[:unit_id]
    @toggle_hash_enable = {}
    @toggle_hash_disable = {}
    @toggle_hash_enable["location_ref_id"] = _unit_id.to_s
    @toggle_hash_disable["location_ref_id"] = _unit_id.to_s
    @toggle_hash_enable["item_ref_ids"] = []
    @toggle_hash_disable["item_ref_ids"] = []
    JSON.parse(params[:toggle_item_id]).each do |i|
      _parent_mp = MenuProduct.find(i).parent_menu_product
      _child_mp = MenuProduct.find(i)
      if _parent_mp.present?
        if _child_mp.sold_at_store
          if _child_mp.mode == 1
            @toggle_hash_enable["item_ref_ids"].push(_parent_mp.id.to_s)
            @toggle_hash_enable["action"] = "enable"
          else
            @toggle_hash_disable["item_ref_ids"].push(_parent_mp.id.to_s)
            @toggle_hash_disable["action"] = "disable"
          end
        end
      end
    end

    if @toggle_hash_enable["item_ref_ids"].count > 0
      @menu_toggled=ThirdpartyUrbanpiper.thirdparty_urbanpiper_channel_toggle(@thirdparty_dtl,@toggle_hash_enable.to_json)
      if @menu_toggled == true
        @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "enable" }
        @message_arr.push(@message_hash)
      else
        @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "enable" }
        @message_arr.push(@message_hash)
      end
    end
    sleep 5
    if @toggle_hash_disable["item_ref_ids"].count > 0
      @menu_toggled=ThirdpartyUrbanpiper.thirdparty_urbanpiper_channel_toggle(@thirdparty_dtl,@toggle_hash_disable.to_json)
      if @menu_toggled == true
        @message_hash = {"status" => true, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "disable" }
        @message_arr.push(@message_hash)
      else
        @message_hash = {"status" => false, "message" => "#{Unit.find(_unit_id).unit_name}", "process" => "disable" }
        @message_arr.push(@message_hash)
      end
    end
    _enable_message = "<b>Enable:</b><br>"
    _disable_message = "<b>Disable:</b><br>"
    @message_arr.each do |_msg|
      _enable_message = "#{_enable_message} For #{_msg["message"]}, Done successfully.<br>" if _msg["status"] == true && _msg["process"] == "enable"
      _enable_message = "#{_enable_message} <font color='red'>For #{_msg["message"]}, Failed.</font><br>" if _msg["status"] == false && _msg["process"] == "enable"
      _disable_message = "#{_disable_message} For #{_msg["message"]}, Done successfully.<br>" if _msg["status"] == true && _msg["process"] == "disable"
      _disable_message = "#{_disable_message} <font color='red'>For #{_msg["message"]}, Failed.</font><br>" if _msg["status"] == false && _msg["process"] == "disable"
    end
    redirect_to :back, notice: "#{_enable_message}<br>#{_disable_message}".html_safe
  end

  def quick_update
    begin
      @menu_product = MenuProduct.find(params[:id])
      _tax_group = TaxGroup.find(params[:tax_group_id])
      if AppConfiguration.get_config_value('variable_tax') == 'enabled'
        @total_amnt = 0
        _tax_group.tax_classes.each do |tc|
          if tc.tax_type == 'variable'
            if (tc.lower_limit..tc.upper_limit).include?(@menu_product.sell_price_without_tax)
              @total_amnt = @total_amnt + tc[:ammount].to_f
            end 
          else
            @total_amnt = @total_amnt + tc[:ammount].to_f    
          end
        end
        _sell_price = params[:sell_price_wot].to_f + (params[:sell_price_wot].to_f * @total_amnt.to_f / 100)
      else  
        _sell_price = params[:sell_price_wot].to_f + (params[:sell_price_wot].to_f * _tax_group.total_amnt.to_f / 100)
      end

      @menu_product.update_attributes(:mode=> params[:mode], :tax_group_id=> params[:tax_group_id], :sell_price_without_tax=> params[:sell_price_wot], :sell_price=> _sell_price, :procured_price=> params[:procured_price],:alpha_promotion_id=> params[:promo_id],:bill_destination_id=> params[:bill_destination_id],:delivery_mode=>params[:delivery_mode],:max_order_qty=>params[:max_order_qty], :commission_capping_type=>params[:commission_capping_type], :commission_capping=>params[:commission_capping],:is_unit_currency=>params[:is_unit_currency],:unit_currency_price=>params[:unit_currency_price])
      if AppConfiguration.get_config_value('retail_menu') == "enabled"
        if @menu_product.product.lots.by_store(@menu_product.store_id).present?
          @menu_product.product.lots.by_store(@menu_product.store_id).each do |lot|
            lot.update_tax_group  if lot.expiry_date >= Date.today
          end 
        end   
      end 

      # Coded By ABDUL START
      _mc_id = @menu_product.menu_card_id
      _all_mc_ids = []
      _all_mc_ids = MenuCard.set_copy_menu_ids(_mc_id,_all_mc_ids)
      @all_menu_cards = MenuCard.by_menu_card_in(_all_mc_ids)
        
      @all_menu_cards.each do |mc|
        @cloned_menu_product=MenuProduct.find_by_menu_card_id_and_product_id(mc.id,@menu_product.product_id)
        if @cloned_menu_product.present?
          @cloned_menu_product.update_attributes(:mode=> params[:mode], :tax_group_id=> params[:tax_group_id], :sell_price_without_tax=> params[:sell_price_wot], :sell_price=> _sell_price, :procured_price=> params[:procured_price],:alpha_promotion_id=> params[:promo_id],:bill_destination_id=> params[:bill_destination_id],:delivery_mode=>params[:delivery_mode],:max_order_qty=>params[:max_order_qty], :commission_capping_type=>params[:commission_capping_type], :commission_capping=>params[:commission_capping], :is_unit_currency=>params[:is_unit_currency])
          if AppConfiguration.get_config_value('retail_menu') == "enabled"
            if @cloned_menu_product.product.lots.by_store(@menu_product.store_id).present?
              @cloned_menu_product.product.lots.by_store(@menu_product.store_id).each do |lot|
                lot.update_tax_group  if lot.expiry_date >= Date.today
              end 
            end   
          end
        end
      end
      # Coded By ABDUL END

      # Commant By ABDUL START
      # if current_user.role.name == "owner"  # FOR OWNER USER TYPE
        
      #   @all_menu_cards = MenuCard.by_master_menu_id(@menu_product.menu_card_id)
        
      #   @all_menu_cards.each do |mc|
      #     @cloned_menu_product=MenuProduct.find_by_menu_card_id_and_product_id(mc.id,@menu_product.product_id)
      #     @cloned_menu_product.update_attributes(:mode=> params[:mode], :tax_group_id=> params[:tax_group_id], :sell_price_without_tax=> params[:sell_price_wot], :sell_price=> _sell_price, :procured_price=> params[:procured_price],:alpha_promotion_id=> params[:promo_id],:bill_destination_id=> params[:bill_destination_id],:delivery_mode=>params[:delivery_mode],:max_order_qty=>params[:max_order_qty], :commission_capping_type=>params[:commission_capping_type], :commission_capping=>params[:commission_capping])
      #     if AppConfiguration.get_config_value('retail_menu') == "enabled"
      #       if @cloned_menu_product.lots.present?
      #         @cloned_menu_product.lots.each do |lot|
      #           lot.update_tax_group  if lot.expiry_date >= Date.today
      #         end 
      #       end   
      #     end 
      #   end
      # elsif current_user.role.name == "dc_manager"
      #   @all_outlet_units=Unit.by_unit_parent(current_user.unit.id)
      #   @all_outlet_units.each do |unt|
      #     @all_menu_cards = MenuCard.by_master_menu_id_and_unit_id(@menu_product.menu_card_id,unt.id)
      #     @all_menu_cards.each do |mc|
      #       @cloned_menu_product=MenuProduct.find_by_menu_card_id_and_product_id(mc.id,@menu_product.product_id)
      #       @cloned_menu_product.update_attributes(:mode=> params[:mode], :tax_group_id=> params[:tax_group_id], :sell_price_without_tax=> params[:sell_price_wot], :sell_price=> _sell_price, :procured_price=> params[:procured_price],:alpha_promotion_id=> params[:promo_id],:bill_destination_id=> params[:bill_destination_id],:delivery_mode=>params[:delivery_mode],:max_order_qty=>params[:max_order_qty], :commission_capping_type=>params[:commission_capping_type], :commission_capping=>params[:commission_capping])
      #       if AppConfiguration.get_config_value('retail_menu') == "enabled"
      #         if @cloned_menu_product.lots.present?
      #           @cloned_menu_product.lots.each do |lot|
      #             lot.update_tax_group  if lot.expiry_date >= Date.today
      #           end 
      #         end   
      #       end 
      #     end
      #   end
      # end 
      # Commant By ABDUL END

      respond_to do |format|
        format.json { render json: @menu_product }
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      respond_to do |format|
        format.json { render json: {:error=> e.message.to_s}, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_products/1
  # DELETE /menu_products/1.json
  def destroy
    menu_product = MenuProduct.find(params[:id])
    menu_product.menu_product_combinations.each do |mp_mpc|
      mp_mpc.destroy
    end
    menu_product.destroy
    respond_to do |format|
      format.html { redirect_to new_menu_product_path+"?menu_card_id=#{params[:menu_card_id]}", notice: 'Menu product was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        
        if params[:file].present?
          MenuCategory.import(params[:file],params[:unit_id],params[:menu_card_id])
          MenuProduct.import(params[:file],params[:menu_card_id],params[:unit_id],params[:section_id])
        end

        # if params[:file1].present?
        #   MenuCategory.import(params[:file1],params[:unit_id],params[:menu_card_id])
        # end
        redirect_to :back, notice: 'Menu product was successfully saved.'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to :back
    end
  end

  def delete_mp_sale_rule
    @mp_sale_rule = MenuProductSaleRule.find_by_menu_product_id_and_sale_rule_id(params[:menu_product_id],params[:sale_rule_id])
    @mp_sale_rule.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
  private
    def set_module_details
      @module_id = "menu_cards"
      @module_title = I18n.t(:calatog_title)
    end
end
