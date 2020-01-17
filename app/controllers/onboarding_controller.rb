class OnboardingController < ApplicationController
  include Wicked::Wizard
  layout "installation"
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  before_filter :onboarding_progress

  steps :organization, :branch_types, :branches, :user_roles, :users, :vendors, :products, :taxes, :catalogs, :welcome

  def show
    case step
    when :organization
      _business_type_config = AppConfiguration.find_by_config_key('business_type')
      @business_type_config = _business_type_config.present? ? _business_type_config : AppConfiguration.new
      _org_name_config = AppConfiguration.find_by_config_key('organization_name')
      @org_name_config = _org_name_config.present? ? _org_name_config : AppConfiguration.new
    when :branch_types
      @branch_types = Unittype.order('position')
      @iconcolor = 'indigo-text'
    when :branches
      @iconcolor = 'green-2-text'
    when :user_roles
      @user_roles = Role.order('id')
      @iconcolor = 'red-text text-lighten-1'
    when :users
      @users = User.order('id desc')
      @iconcolor = 'amber-text text-darken-2'
    when :vendors
      @vendors = Vendor.order('id desc')
    when :taxes 
      @tax_class = TaxClass.order('id desc')
      @tax_group = TaxGroup.order('id desc')
    when :catalogs
      @menu_card = MenuCard.order('id desc')
    when :products
      @product_unit = ProductUnit.order('id desc')
      @product_basic_unit = ProductBasicUnit.order('id desc')
      @product_scope = Product.get_all
      smart_listing_create :products, @product_scope, partial: "products/products_smartlist", default_sort: {id: "desc"}  
    end
    render_wizard
  end

  def import
    begin
      ActiveRecord::Base.transaction do
        Product.import(params[:file])
        redirect_to :back, notice: 'Products was successfully imported.'
      end      
    rescue Exception => e
      flash[:error] = e.message
     redirect_to :back
    end
  end

  private 
  def onboarding_progress
    @progress = {:overall_progress => 0, :organization_setup => 0, :users_setup => 0, :products_setup => 0, :catalog_setup => 0, :inventory_setup => 0, :operations_setup => 0 }
    _unittypes = Unittype.includes(:units => [:sections, :sections, :sorts ])
    _business_type_config = AppConfiguration.find_by_config_key('business_type')
    _org_name_config = AppConfiguration.find_by_config_key('organization_name')
    if _business_type_config.present?
      @progress[:overall_progress] +=3
      @progress[:organization_setup] +=5
    end
    if _org_name_config.present?
      @progress[:overall_progress] +=1 
      @progress[:organization_setup] +=1 
    end
    # calculating organization progress
    if _unittypes.present?
      @progress[:overall_progress] +=5
      @progress[:organization_setup] +=20
      _unittype_with_unit, _unittype_without_unit = 0,0
      _unittypes.each do |unittype|
        # If unittype have units
        if unittype.units.present?
          _unittype_with_unit +=1
          @progress[:organization_setup] += 1
          unittype.units.each do |unit|

          end
        else
          _unittype_without_unit +=1
        end
        # @progress[:organization_setup] +=20 if (_unittype_without_unit = 0)
        # If each unit have sections, sorts, stores
      end
    end
  end

end
