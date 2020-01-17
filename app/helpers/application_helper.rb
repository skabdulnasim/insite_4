module ApplicationHelper
  require "net/http"
  require 'uri'
  def navtree
    dash_grp_links, callback_grp_links, shop_grp_links, invtry_grp_links,finalcial_account_grp_link,reservation_grp_links,reports_grp_links, prodt_grp_links, org_grp_links, setngs_grp_links, travelling_sales_man_grp_links, sourcing_executives_grp_links, package_grp_links = [], [], [], [], [], [], [], [], [], [], [],[],[]
    # Dashboard Group Links
    dash_grp_links.push({:url => '/home/welcome', :title => 'Dashboard', :controllers => ['home'], :actions => ['welcome']}) if can? :welcome, Home
    # Shop Operations Group Links
    shop_grp_links.push({:url => orders_path, :title => 'Orders', :controllers => ['orders'], :actions => ['index','show']}) if can? :index, Order
    shop_grp_links.push({:url => future_orders_orders_path, :title => 'Future Orders', :controllers => ['orders'], :actions => ['future_orders']}) if can? :future_orders, Order
    shop_grp_links.push({:url => bills_path, :title => 'Bills', :controllers => ['bills'], :actions => ['index','show']}) if can? :index, Bill
    shop_grp_links.push({:url => pos_terminals_path, :title => 'POS Terminals', :controllers => ['pos_terminals'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, PosTerminal and module_enabled? 'pos_terminals'
    #shop_grp_links.push({:url => tables_path, :title => 'Tables', :controllers => ['tables'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Table and module_enabled? 'tables_module'
    shop_grp_links.push({:url => resources_path, :title => 'Resource', :controllers => ['resources'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Resource
    shop_grp_links.push({:url => delivery_boys_path, :title => 'Home Delivery', :controllers => ['delivery_boys'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, DeliveryBoy and module_enabled? 'home_delivery'
    callback_grp_links.push({:url => '/thirdparty_callbacks', :title => 'Callbacks', :controllers => ['thirdparty_callbacks'], :actions => ['index']})
    if AppConfiguration.get_config_value('b2b_billing') == 'enabled'
      shop_grp_links.push({:url=> proformas_path, :title => "Proformas", :controllers => ['proformas'], :actions=> ['index']}) if can? :proformas, Proforma
    end

    # Inventory Operations Group Links

    # invtry_grp_links.push({:url => stores_path, :title => 'Stores', :controllers => ['stores', 'stocks', 'store_requisitions', 'purchase_orders', 'stock_purchases', 'stock_transfers', 'stock_transfer_templates', 'stock_audits', 'stock_productions', 'kitchen_production_audits'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Store and module_enabled? 'inventory_module'
    # invtry_grp_links.push({:url => vendors_path, :title => 'Vendors', :controllers => ['vendors'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Vendor and module_enabled? 'inventory_module'
    # invtry_grp_links.push({:url => vehicles_path, :title => 'Vehicles', :controllers => ['vehicles'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Vehicle and module_enabled? 'shipping_module'
    # invtry_grp_links.push({:url => production_processes_path, :title => 'Processes', :controllers => ['production_processes'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, ProductionProcess and module_enabled? 'inventory_module'
    invtry_grp_links.push({:url => inventory_dashboards_path, :title => 'Inventory', :controllers => ['inventory_dashboards'], :actions => ['index']}) if can? :index, Store and module_enabled? 'inventory_module'
    finalcial_account_grp_link.push({:url => account_details_financial_accounts_path, :title => 'Accounts', :controllers => ['financial_accounts'], :actions => ['account_details']}) if can? :account_details, FinancialAccount and module_enabled? 'b2b_billing'
    #Reservation Group Links
    reservation_grp_links.push({:url => reservations_path, :title => 'Reservation', :controllers => ['reservations'], :actions => ['index']}) if can? :index, Reservation
    reservation_grp_links.push({:url => reservations_list_reservations_path, :title => 'Reservation List', :controllers => ['reservations'], :actions => ['reservations_list']}) if can? :reservations_list, Reservation
    reservation_grp_links.push({:url => customer_queues_path, :title => 'Customer Queues', :controllers => ['customer_queues'], :actions => ['index']}) if can? :index, Reservation
    
    #Package Group Links
    package_grp_links.push({:url => packages_path, :title => 'Package', :controllers => ['packages'], :actions => ['index']}) if module_enabled? 'package_module'

    # Report Group Links
    reports_grp_links.push({:url => sale_reports_path, :title => 'Sales Report', :controllers => ['sale_reports'], :actions => ['index','by_date', 'by_date_range','sale_summery', 'sale_user_wise', 'category_wise', 'sku_wise']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => comprehensive_sale_reports_path, :title => 'Comprehensive Sales Report', :controllers => ['comprehensive_sale_reports'], :actions => ['index','bill_by_bill_report']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => return_item_reports_path, :title => 'Return Reports', :controllers => ['return_item_reports'], :actions => ['index','about']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => nc_report_index_path, :title => 'NC Report', :controllers => ['nc_report'], :actions => ['index','by_date', 'by_date_range','table_wise','category_wise']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => void_reports_path, :title => 'Void Report', :controllers => ['void_reports'], :actions => ['index','by_date']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => inventory_reports_path, :title => 'Inventory Report', :controllers => ['inventory_reports'], :actions => ['index','store_stocks', 'stock_transfer','stock_purchase','stock_consumption', 'store_indent', 'stock_issue', 'avaliable_stock']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => settlement_reports_path, :title => 'Settlement Report', :controllers => ['settlement_reports'], :actions => ['index','card_wise', 'loyalty_card_wise']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => incentive_reports_path, :title => 'Incentive Report', :controllers => ['incentive_reports'], :actions => ['index']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => loyalty_reports_path, :title => 'Loyalty Card Reward Report', :controllers => ['loyalty_reports'], :actions => ['index','by_date']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => kot_reports_path, :title => 'Kot Report', :controllers => ['kot_report'], :actions => ['index','void_kot_report']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => reservation_reports_path, :title => 'Reservation Report', :controllers => ['reservation_report'], :actions => ['index','reservation_report']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => report_folders_path, :title => 'Old Reports', :controllers => ['report_folders', 'custom_reports'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => delivery_reports_path, :title => 'Delivery Report', :controllers => ['delivery_reports'], :actions => ['index','slot_specific_delivery_reports','delivery_boys_report']}) if can? :index, ReportFolder
    if current_user.users_role.role.name == "owner" 
      reports_grp_links.push({:url => user_role_reports_path, :title => 'Roles Permission Report', :controllers => ['report_folders', 'user_role_reports'], :actions => ['index']}) if can? :index, ReportFolder
    end
    reports_grp_links.push({:url => customer_reports_path, :title => 'Customer Details Report', :controllers => ['customer_reports'], :actions => ['index','customer_details']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => user_login_logouts_path, :title => 'Authentication Details Report', :controllers => ['user_login_logouts'], :actions => ['index','by_date']}) if can? :index, ReportFolder
    reports_grp_links.push({:url => order_reports_path, :title => 'Order Report', :controllers => ['order_reports'], :actions => ['index','home_delivery_order_reports']}) if can? :index, ReportFolder

    # Product Group Links
    prodt_grp_links.push({:url => menu_cards_path, :title => 'Catalogs', :controllers => ['menu_cards'], :actions => ['index','show', 'new','create', 'edit', 'update', 'add_products', 'copy']}) if can? :index, MenuCard
    prodt_grp_links.push({:url => menu_cards_manage_settings_path, :title => 'Catalog Rules', :controllers => ['menu_cards'], :actions => ['manage_settings']}) if can? :manage_settings, MenuCard
    prodt_grp_links.push({:url => menu_mappings_path, :title => 'Menu Mapping', :controllers => ['menu_mappings'], :actions => ['new','create','show','edit','update']}) if can? :index, MenuMapping and module_enabled? 'menu_merge'
    prodt_grp_links.push({:url => products_path, :title => 'Products Master', :controllers => ['products'], :actions => ['index','show', 'new','create', 'edit', 'update', 'new_import', 'import']}) if can? :index, Product
    prodt_grp_links.push({:url => unit_products_products_path, :title => 'Branch Products', :controllers => ['products'], :actions => ['unit_products','add_products', 'save_products','remove_unit_product']}) if can? :unit_products, Product
    prodt_grp_links.push({:url => categories_path, :title => 'Product Categories', :controllers => ['categories'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Category
    prodt_grp_links.push({:url => cost_categories_path, :title => 'Cost Categories', :controllers => ['cost_categories'], :actions => ['index','show', 'new','create', 'edit', 'update']})
    prodt_grp_links.push({:url => product_attribute_sets_path, :title => 'Product Attributes', :controllers => ['product_attribute_sets', 'product_attribute_groups', 'product_attribute_keys'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, ProductAttributeSet
    prodt_grp_links.push({:url => products_settings_path, :title => 'Product Settings', :controllers => ['products'], :actions => ['settings']}) if can? :settings, Product
    prodt_grp_links.push({:url => addons_groups_path, :title => 'Addons Groups', :controllers => ['addons_groups'], :actions => ['index','show', 'new','create', 'edit', 'update']})
    prodt_grp_links.push({:url => tag_groups_path, :title => 'Tag Groups', :controllers => ['tag_groups'], :actions => ['index','show', 'new','create', 'edit', 'update']})
    prodt_grp_links.push({:url => tags_path, :title => 'Tags', :controllers => ['tags'], :actions => ['index','show', 'new','create', 'edit', 'update']})

    # Organization Group Links

    org_grp_links.push({:url => units_path, :title => 'All Branches', :controllers => ['units'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Unit
    org_grp_links.push({:url => new_unit_detail_path, :title => 'Organization Profile', :controllers => ['unit_details'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, UnitDetail
    org_grp_links.push({:url => sections_path, :title => 'Sections', :controllers => ['sections'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Section
    org_grp_links.push({:url => sorts_path, :title => 'SORT', :controllers => ['sorts'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Sort
    org_grp_links.push({:url => loyalty_cards_path, :title => 'Loyalty Cards', :controllers => ['loyalty_cards', 'loyalty_card_classes'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, LoyaltyCard and module_enabled? 'loyalty_cards'
    org_grp_links.push({:url => advertisements_path, :title => 'Advertisements', :controllers => ['advertisements'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, Advertisement
    org_grp_links.push({:url => users_path, :title => 'User', :controllers => ['users'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, User
    org_grp_links.push({:url => access_manager_index_path, :title => 'Roles & Access Control', :controllers => ['access_manager'], :actions => ['index','show']}) if can? :index, AccessManager
    org_grp_links.push({:url => incentive_rules_path, :title => 'Incentive Rule Control', :controllers => ['incentive_rules'], :actions => ['index']}) if can? :index, IncentiveRule
    org_grp_links.push({:url => slots_path, :title => 'Slots', :controllers => ['slots'], :actions => ['index','show']}) if can? :index, Slot
    org_grp_links.push({:url => expected_currencies_path, :title => 'Accepted Currency', :controllers => ['expected_currencies'], :actions => ['index']})

    org_grp_links.push({:url => resource_types_path, :title => 'Resource Types', :controllers => ['resource_types'], :actions => ['index','show']}) if can? :index, ResourceType
    org_grp_links.push({:url => resources_path, :title => 'Resource', :controllers => ['resources'], :actions => ['index','show']}) if can? :index, Resource
    org_grp_links.push({:url => availabilities_path, :title => 'Availability', :controllers => ['Availabilities'], :actions => ['index','show']}) if can? :index, Availability
    org_grp_links.push({:url => resource_states_path, :title => 'Resource State', :controllers => ['rresource_states'], :actions => ['index','show','new']}) if can? :index, ResourceState
    org_grp_links.push({:url => feedbacks_path, :title => 'Feedback', :controllers => ['feedbacks'], :actions => ['index','show','new']}) if can? :index, Feedback
    org_grp_links.push({:url => questions_path, :title => 'Question', :controllers => ['questions'], :actions => ['index','show','new','edit','update']}) if can? :index, Question
    org_grp_links.push({:url => cash_handlings_path, :title => 'Cash Handling', :controllers => ['cash_handlings'], :actions => ['index']}) if can? :index, CashIn
    org_grp_links.push({:url => upi_merchants_path, :title => 'UPI Merchant Settings', :controllers => ['upi_merchants'], :actions => ['index']}) if can? :index, UpiMerchant
    if current_user.users_role.role.name == "owner" 
      org_grp_links.push({:url => paytm_securities_path, :title => 'Paytm Configurations', :controllers => ['paytm_securities'], :actions => ['index']}) if can? :index, PaytmSecurity
    end
    org_grp_links.push({:url => cancelation_policies_path, :title => 'Cancelation policies', :controllers => ['cancelation_policies'], :actions => ['index','new','create']}) if can? :index, CancelationPolicy
    org_grp_links.push({:url => return_policies_path, :title => 'Return policies', :controllers => ['return_policies'], :actions => ['index','new','create']}) if can? :index, ReturnPolicy
    org_grp_links.push({:url => delivery_charges_path, :title => 'Delivery Charges', :controllers => ['delivery_charges'], :actions => ['index','new','create']}) if can? :index, DeliveryCharge
    org_grp_links.push({:url => delivery_addresses_path, :title => 'Delivery Address', :controllers => ['delivery_addresses'], :actions => ['index','new','create']}) if can? :index, DeliveryAddress
    org_grp_links.push({:url => tally_xml_exporter_index_path, :title => 'TallyXmlExporter', :controllers => ['tally_xml_exporter'], :actions => ['index','show','new']})
    org_grp_links.push({:url => customers_path, :title => 'Customer', :controllers => ['customers'], :actions => ['index']}) if can? :index, User
    org_grp_links.push({:url => allergies_path, :title => 'Allergies', :controllers => ['allergies'], :actions => ['index']}) if can? :index, Allergy
    org_grp_links.push({:url => product_religions_path, :title => 'Product religions', :controllers => ['product_religions'], :actions => ['index']}) if can? :index, ProductReligion
    org_grp_links.push({:url => sale_rules_path, :title => 'Sale Rules', :controllers => ['sale_rules'], :actions => ['index']}) if can? :index, SaleRule
    org_grp_links.push({:url => bill_destinations_path, :title => 'Bill Destinations', :controllers => ['bill_destinations'], :actions => ['index']}) if can? :index, BillDestination
    org_grp_links.push({:url => model_actions_path, :title => 'Reason Codes', :controllers => ['model_actions'], :actions => ['index']}) if can? :index, ModelAction

    # Settings group Links
    setngs_grp_links.push({:url => app_configurations_path, :title => 'Configurations', :controllers => ['app_configurations'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, AppConfiguration
    setngs_grp_links.push({:url => developer_apps_path, :title => 'Developer Apps', :controllers => ['developer_apps'], :actions => ['index','show', 'new','create', 'edit', 'update']}) if can? :index, DeveloperApp
    setngs_grp_links.push({:url => printers_app_configurations_path, :title => 'Printers', :controllers => ['app_configurations'], :actions => ['printers']}) if can? :printers, AppConfiguration
    setngs_grp_links.push({:url => orders_manage_settings_path, :title => 'Order Settings', :controllers => [''], :actions => ['manage_settings']}) if can? :manage_settings, Order
    setngs_grp_links.push({:url => manage_settings_tables_path, :title => 'Table Settings', :controllers => [''], :actions => ['manage_settings']}) if can? :manage_settings, Table

    # Sales persons grp links  
    travelling_sales_man_grp_links.push({:url => '/sales_persons/', :title => 'Allocation', :controllers => ['sales_persons'], :actions => ['index']}) if can? :index, SalesPerson and module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => '/inspections/', :title => 'Inspection', :controllers => ['inspections'], :actions => ['index']}) if module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => '/resources/retail_shops_list/', :title => 'Retail Shops', :controllers => ['resources'], :actions => ['retail_shops_list']}) if module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => "http://195.201.42.200:8003/map_view?id=#{@current_user.id}", :title => 'Map Timeline', :controllers => [], :actions => []}) if module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => '/tsp_reports/', :title => 'TSE Reports', :controllers => ['tsp_reports'], :actions => ['index']}) if module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => '/bits/', :title => 'Bits', :controllers => ['bits'], :actions => ['index']}) if module_enabled? 'tsp_module' and  module_enabled? 'bit_wise_resource_allocation'
    travelling_sales_man_grp_links.push({:url => '/resource_managements/', :title => 'Manage Resource', :controllers => ['resource_managements'], :actions => ['index']}) if module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => '/resource_order_histories/', :title => 'Resource Order History', :controllers => ['resource_order_histories'], :actions => ['index']}) if module_enabled? 'tsp_module'
    travelling_sales_man_grp_links.push({:url => '/user_targets/', :title => 'User Target', :controllers => ['user_targets'], :actions => ['index']}) if module_enabled? 'tsp_module'
    
    # Sourcing Executives grp links
    sourcing_executives_grp_links.push({:url => '/vendor_product_prices/', :title => 'Sourcing Details', :controllers => ['vendor_product_prices'], :actions => ['index']}) if module_enabled? 'sourceing_exe_module'
    sourcing_executives_grp_links.push({:url => '/sourcing_executives/', :title => 'Allocation', :controllers => ['sourcing_executives'], :actions => ['index']}) if module_enabled? 'sourceing_exe_module'
    sourcing_executives_grp_links.push({:url => '/sourcing_executives/vendor_inspections', :title => 'Inspection', :controllers => ['sourcing_executives'], :actions => ['vendor_inspections']}) if module_enabled? 'sourceing_exe_module'
    sourcing_executives_grp_links.push({:url => '/se_reports/', :title => 'SE Reports', :controllers => ['se_reports'], :actions => ['index']}) if module_enabled? 'sourceing_exe_module'

    tree = [
      {
        :group_title        => 'Dashboard', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-action-dashboard",
        :is_visible         => true,
        :group_controllers  => ['home'], # Array of controllers that will be available under this group
        :group_links        => dash_grp_links
      }, {
        # :group_title        => 'Shop Operations', # This will be visible in menu
        :group_title        => 'Operations',
        :group_url          => "#!",
        :group_icon         => "mdi-action-shopping-cart",
        :is_visible         => true,
        :group_controllers  => ['orders', 'bills', 'tables', 'pos_terminals'], # Array of controllers that will be available under this group
        :group_links        => shop_grp_links
      },{
        # :group_title        => 'Shop Operations', # This will be visible in menu
        :group_title        => 'Accounts',
        :group_url          => "#!",
        :group_icon         => "fa fa-calculator",
        :is_visible         => true,
        :group_controllers  => ['financial_accounts'], # Array of controllers that will be available under this group
        :group_links        => finalcial_account_grp_link
      },{
        :group_title        => 'Travelling Sales Executive', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "fa fa-bicycle",
        :is_visible         => true,
        :group_controllers  => ['sales_persons'], # Array of controllers that will be available under this group
        :group_links        => travelling_sales_man_grp_links
      }, {
        :group_title        => 'Sourcing Executive', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "fa fa-motorcycle",
        :is_visible         => true,
        :group_controllers  => ['sourcing_executives', 'vendor_product_prices'], # Array of controllers that will be available under this group
        :group_links        => sourcing_executives_grp_links
      }, {
        :group_title        => 'Reports', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-av-equalizer",
        :is_visible         => true,
        :group_controllers  => ['sale_reports','comprehensive_sale_reports','return_item_reports','nc_report', 'inventory_reports', 'settlement_reports', 'loyalty_reports', 'report_folders', 'custom_reports', 'user_role_reports', 'order_reports'], # Array of controllers that will be available under this group
        :group_links        => reports_grp_links
      }, {
        :group_title        => 'Inventory Operations', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-device-now-widgets",
        :is_visible         => true,
        :group_controllers  => ['stores', 'stocks', 'store_requisitions', 'purchase_orders', 'stock_purchases', 'stock_transfers', 'stock_transfer_templates', 'stock_audits', 'stock_productions', 'kitchen_production_audits', 'vendors', 'vehicles'], # Array of controllers that will be available under this group
        :group_links        => invtry_grp_links
      },{
        :group_title        => 'Reservations', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-action-view-module",
        :is_visible         => true,
        :group_controllers  => ['reservations'], # Array of controllers that will be available under this group
        :group_links        => reservation_grp_links
      },{
        :group_title        => 'Packages', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-action-view-module",
        :is_visible         => true,
        :group_controllers  => ['packages'], # Array of controllers that will be available under this group
        :group_links        => package_grp_links
      },{
        :group_title        => 'Catalogs & Products', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-action-view-carousel",
        :is_visible         => true,
        :group_controllers  => ['menu_cards', 'products', 'categories', 'product_attribute_sets', 'product_attribute_groups', 'product_attribute_keys', 'addons_groups'], # Array of controllers that will be available under this group
        :group_links        => prodt_grp_links
      }, {
        :group_title        => 'Organization Structure', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-maps-store-mall-directory",
        :is_visible         => true,
        :group_controllers  => ['units', 'unit_details', 'sections', 'sorts', 'users', 'loyalty_cards', 'advertisements', 'printers_app_configurations', 'access_manager','cancelation_policies','return_policies'], # Array of controllers that will be available under this group
        :group_links        => org_grp_links
      }, {
        :group_title        => 'Settings', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-action-settings",
        :is_visible         => true,
        :group_controllers  => ['app_configurations', 'developer_apps'], # Array of controllers that will be available under this group
        :group_links        => setngs_grp_links
      }, {
        :group_title        => 'Callbacks', # This will be visible in menu
        :group_url          => "#!",
        :group_icon         => "mdi-action-autorenew",
        :is_visible         => true,
        :group_controllers  => ['thirdparty_callbacks'], # Array of controllers that will be available under this group
        :group_links        => callback_grp_links
      }
    ]
  end

  def render_sidenavbar_links active_controller, active_action
    concat(content_tag(:div) {
      navtree.each do |object|
        if (object[:group_links].length == 1) and (object[:is_visible] == true)
          build_navbar_link object[:group_links][0][:url], object[:group_links][0][:title], object[:group_icon], object[:group_links][0][:controllers], object[:group_links][0][:actions], active_controller, active_action
        elsif (object[:group_links].length > 0) and object[:is_visible] == true
          build_navgroup_link object, active_controller, active_action
        end
      end
    })
  end

  def build_navgroup_link navgroup, active_controller, active_action
    concat(content_tag(:li, class: "no-padding") {
      concat(content_tag(:ul, class: "collapsible collapsible-accordion") {
        concat(content_tag(:li, class: "bold #{active_controller_class(active_controller, navgroup[:group_controllers])}") {
          concat(content_tag(:a, class: "collapsible-header waves-effect waves-grey #{active_controller_class(active_controller, navgroup[:group_controllers])}") {
            concat(content_tag(:i, "", class: "#{navgroup[:group_icon]}"))
            concat(navgroup[:group_title])
          })
          concat(content_tag(:div, class: "collapsible-body") {
            concat(content_tag(:ul){
              navgroup[:group_links].each do |link|
                build_navbar_link link[:url], link[:title], link[:icon], link[:controllers], link[:actions], active_controller, active_action
              end
            })
          })
        })
      })
    })
  end

  def build_navbar_link url, title, icon='', controllers, actions, active_controller, active_action
    concat(content_tag(:li, class: ["#{active_action_class(controllers, actions, active_controller, active_action)}"]) {
      concat(content_tag(:a, href: url, class: "waves-effect waves-grey") {
        concat(content_tag(:i, "", class: "#{icon}"))
        concat(title)
      })
    })
  end

  def active_controller_class active_controller, link_controllers
    (link_controllers.include? active_controller) ? 'active' : ''
  end

  def active_action_class controllers, actions, active_controller, active_action
    (actions.include? active_action and controllers.include? active_controller) ? 'active' : ''
  end

  # Check if module enabled in site config or not
  def module_enabled? key
    (AppConfiguration.get_config_value(key) == 'enabled') ? true : false
  end

  def currency
    return Account.find_by_subdomain(request.subdomain).currency.presence || "Rs"
  end

  def unit_currency(unit_id)
    unit = Unit.find(unit_id)
    unit_currency = unit.unit_currency
    return unit_currency
  end  

  def manual_load_javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def broadcast(channel, &block)
    message = {:channel => channel, :data=> capture(&block), :ext => {:auth_token => FAYE_TOKEN}}
    uri = URI.parse(FAYE_SERVER_URL)
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def get_unit_push_channel_name(client_type,_channel_last_name)
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channel = "/notifications/#{client_type}/subdomain/#{_subdomain.config_value.to_s}/unit/#{current_user.unit_id}/#{_channel_last_name}"
  end

  def get_module_name(_module_id,_module_title)
    if _module_id == 'pos_terminals'
      concat(content_tag(:i, '', :class => 'mdi-hardware-desktop-mac'))
    elsif _module_id == 'bills'
      concat(content_tag(:i, '', :class => 'mdi-action-payment'))
    elsif _module_id == 'orders'
      concat(content_tag(:i, '', :class => 'mdi-action-shopping-cart'))
    elsif _module_id == 'dashboard'
      concat(content_tag(:i, '', :class => 'mdi-action-dashboard'))
    elsif _module_id == 'inventory'
      concat(content_tag(:i, '', :class => 'mdi-device-now-widgets'))
    elsif _module_id == 'app_config'
      concat(content_tag(:i, '', :class => 'mdi-action-settings'))
    elsif _module_id == 'products'
      concat(content_tag(:i, '', :class => 'mdi-maps-layers'))
    elsif _module_id == 'vendors'
      concat(content_tag(:i, '', :class => 'fa fa-tags fa-lg margin-r-10'))
    elsif _module_id == 'vehicles'
      concat(content_tag(:i, '', :class => 'mdi-maps-local-shipping'))
    elsif _module_id == 'menu_cards'
      concat(content_tag(:i, '', :class => 'mdi-action-view-carousel'))
    elsif _module_id == 'units'
      concat(content_tag(:i, '', :class => 'mdi-maps-store-mall-directory'))
    elsif _module_id == 'users'
      concat(content_tag(:i, '', :class => 'mdi-social-people'))
    elsif _module_id == 'authorization'
      concat(content_tag(:i, '', :class => 'mdi-action-verified-user'))
    elsif _module_id == 'tables'
      concat(content_tag(:i, '', :class => 'mdi-content-flag'))
    elsif _module_id == 'reports'
      concat(content_tag(:i, '', :class => 'mdi-av-equalizer'))
    elsif _module_id == 'third_party'
      concat(content_tag(:i, '', :class => 'mdi-action-launch'))
    elsif _module_id == 'loyalty_cards'
      concat(content_tag(:i, '', :class => 'mdi-action-loyalty'))
    elsif _module_id == 'sort'
      concat(content_tag(:i, '', :class => 'mdi-av-loop'))
    elsif _module_id == 'sections'
      concat(content_tag(:i, '', :class => 'mdi-content-select-all'))
    elsif _module_id == 'tax_groups'
      concat(content_tag(:i, '', :class => 'mdi-maps-local-atm'))
    elsif _module_id == 'advertisements'
      concat(content_tag(:i, '', :class => 'mdi-maps-local-play'))
    elsif _module_id == 'dev_apps'
      concat(content_tag(:i, '', :class => 'mdi-notification-adb'))
    end
    concat(content_tag(:span, _module_title))
  end

  def render_page_breadcrumbs(links_arr)
    concat(content_tag(:div, class: ["col-fv-breadcrumb"]) {
      concat(content_tag(:ul, class: ["col-fv-breadcrumbs"]) {
        _length = links_arr.length
        links_arr.each do |la|
          concat(content_tag(:li,class: ["#{la[:active_class]}"], style: ["z-index: #{_length}"]) {
            concat(link_to la[:title], la[:url], :class => "col-fv-breadcrumb-text")
          })
          _length -= 1
        end
      })
    })
  end

  def error_messages_for(*objects)
    html = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    if errors.any?
      html << "<div id='errorExplanation'><ul>\n"
      errors.each do |error|
        html << "<li>#{h error}</li>\n"
      end
      html << "</ul></div>\n"
    end
    html.html_safe
  end

  def get_stock_details(product_id,current_user)
    unit_ids = []
    unit_ids << current_user.unit.id
    current_user.unit.children.map { |e| unit_ids.push e.id } if current_user.unit.children.present?
    @stores = Store.set_unit_in(unit_ids).not_return
    @str = ""
    @stores.each do |store|
      stock = get_store_product_data(product_id,store.id)
      @str = "#{@str + store.name}"": #{stock}  " +"<br/>"  if stock > 0
    end  
    return @str
    
  end

  def link_to_add_fields name, f, association, data_attributes={}, css_classes=''
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id, :html => { :class => 'abc'}) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    default_data = {id: id, fields: fields.gsub("\n", "")}
    link_to(name, "#", class: "add_fields #{css_classes}", data: default_data.reverse_merge!(data_attributes))
  end

  def get_unit_available_credit(unit_id)
    _unit_details = Unit.find(unit_id)
    _unit_stores = Store.unit_stores(unit_id).physical
    _total_bill = 0.0
    _unit_stores.each do |us|
      _store_id = us.id
      _purchase_bill = Stock.set_store(_store_id).set_transaction_type('StockPurchase').type_credit.sum(:price)
      _trans_bill = Stock.set_store(_store_id).set_transaction_type('StockTransfer').type_credit.sum(:price)
      _production_bill = Stock.set_store(_store_id).set_transaction_type('StockProduction').type_credit.sum(:price)
      _total_bill = _total_bill + _purchase_bill.to_f + _trans_bill.to_f + _production_bill.to_f
    end
    _current_credit = ((_unit_details.credit_limit).to_f) - _total_bill
    return _current_credit
  end

  def get_product_current_stock(store, product)
    _stock = StockUpdate.current_stock(store, product)
    return _stock
  end

  def get_product_sku_stock(store, product, sku)
    _stock = StockUpdate.current_sku_stock(store, product, sku)
    return _stock.to_f
  end

  def get_unit_current_cash(unit_id, from_datetime, to_datetime)
    _current_cash = Pay.get_unit_cash_data(unit_id, from_datetime, to_datetime)
    return _current_cash
  end

  def get_product_current_stock_cost(store, product)
    _stock_cost = Stock.current_stock_cost(store, product)
    puts "************************"
    puts _stock_cost.inspect
    return _stock_cost
  end

  def get_product_secondary_stock(store_id, product_id)
    _stock = SecondaryStock.current_stock_string(store_id, product_id)
  end
  # => Getting product logo
  # @params :product_image => "Product Image",
  def get_product_image(product)
    if product.product_images.present?
      image_tag("#{product.product_images.first.image}", alt: product.name, height: '180')
    else
      image_tag("/uploads/flatico/Packing2.png", height: '180')
    end

  end

  def get_product_logo(product_image)
    if !product_image.present?
      image_tag("icons/product-box-128.png", width: '60', :class => "img-thumbnail")
    else
      image_tag("#{product_image.first.image}", width: '50', :class => "img-thumbnail")
    end
  end

  def get_vendor_product_logo(product_image)
    if !product_image.present?
      image_tag("icons/product-box-128.png", width: '30', :class => "img-thumbnail")
    else
      image_tag("#{product_image.first.image}", width: '30', :class => "img-thumbnail")
    end
  end

  def get_stock_entry_details(stock_id)
    _stock = Stock.find(stock_id)
    return _stock
  end

  def build_product_categories
    _categories = Category.all
    _cat_arr = []
    _categories.each do |ca|
      if ca.parent.blank?
        _sub_arr = {}
        _sub_arr[:id] = ca.id.to_i
        _sub_arr[:name] = ca.name
        _sub_arr[:parent] = ca.parent
        _cat_arr.push(_sub_arr)
        build_product_sub_categories(ca.id.to_i,_cat_arr,1)
      end
    end
    return _cat_arr
  end

  def build_product_sub_categories(cat_id,_cat_arr,space)
    _categories = Category.where('parent =?', cat_id)
    _name_space = product_category_name_space(space)
    _categories.each do |ca|
      _sub_arr = {}
      _sub_arr[:id] = ca.id.to_i
      _sub_arr[:name] = _name_space.to_s + ca.name.to_s
      _sub_arr[:parent] = ca.parent
      _cat_arr.push(_sub_arr)
      build_product_sub_categories(ca.id.to_i,_cat_arr,(space+1))
    end
  end

  def build_menu_categories(menu_card_id)
    _categories = MenuCard.find(menu_card_id).menu_categories
    _cat_arr = []
    _categories.each do |ca|
      if ca.parent.blank?
        _sub_arr = {}
        _sub_arr[:id] = ca.id.to_i
        _sub_arr[:name] = ca.name
        _sub_arr[:parent] = ca.parent
        _cat_arr.push(_sub_arr)
        build_menu_sub_categories(ca.id.to_i,_cat_arr,1)
      end
    end
    return _cat_arr
  end

  def build_menu_sub_categories(cat_id,_cat_arr,space)
    _categories = MenuCategory.where('parent =?', cat_id)
    _name_space = product_category_name_space(space)
    _categories.each do |ca|
      _sub_arr = {}
      _sub_arr[:id] = ca.id.to_i
      _sub_arr[:name] = _name_space.to_s + ca.name.to_s
      _sub_arr[:parent] = ca.parent
      _cat_arr.push(_sub_arr)
      build_menu_sub_categories(ca.id.to_i,_cat_arr,(space+1))
    end
  end

  def product_category_name_space(space)
    str = ""
    while space > 0  do
      str = str + "-- "
      space -=1
    end
    return str
  end

  def get_todays_total_sales(_unit_id)
    _total_sales = Bill.unit_bills(_unit_id).by_recorded_at(@today_from_datetime,@today_to_datetime).sum(:grand_total)
  end

  def get_todays_nc_void_loss(_unit_id)
    _total_loss = Bill.invalid_bill.unit_bills(_unit_id).by_recorded_at(@today_from_datetime,@today_to_datetime).sum(:bill_amount)
  end

  def get_todays_paid_sales(_unit_id)
    _paid = Bill.unit_bills(_unit_id).by_recorded_at(@today_from_datetime,@today_to_datetime).paid.sum(:grand_total)
  end

  def get_unit_bill_data(_unit_id,from_datetime,to_datetime)
    total_sate = Bill.get_unit_bill_data(_unit_id,from_datetime,to_datetime)  
  end
  
  def get_todays_unpaid_sales(_unit_id)
    _unpaid = Bill.unit_bills(_unit_id).by_recorded_at(@today_from_datetime,@today_to_datetime).unpaid.sum(:grand_total)
  end

  def get_to_day_return_amount(_unit_id)
    _total_return = ReturnItem.unit_return(_unit_id).by_date_range(@today_from_datetime,@today_to_datetime).sum(:price)  
  end

  def get_return_adjustment_amount(_unit_id)
    _total_adjustment_amount =WalletTransaction.where(:id=>Bill.unit_bills(_unit_id).by_recorded_at(@today_from_datetime,@today_to_datetime).joins(:payments).where(payments: { paymentmode_type: 'WalletTransaction' }).pluck(:paymentmode_id)).sum(:amount)  
  end

  def get_to_day_distinct_product_count(_unit_id)
    _total_item_count = ReturnItem.unit_return(_unit_id).by_date_range(@today_from_datetime,@today_to_datetime).count 
  end

  def today_orders
    OrderManagement::order_no_by_date(Time.zone.now.beginning_of_day, current_user[:unit_id])
  end

  def current_unit_order
    order_scope = Order.check_order_unit(current_user.unit_id).today.not_canceled.not_billed.asc
  end

  def show_percentage(order)
    case order.order_status.name.downcase
      when "new"
        return "15%"
      when "approved"
        return "30%"
      when "preparing"
        return "45%"
      when "prepared"
        return "75%"
      when "delivered"
        return "90%"
      else
        return "100%"
    end
  end

  def object_action_link(object, model, action, size)
    # edit_object_path = "edit_#{model}_path"
    model_plural = model.pluralize
    if action == "new" then
      path = "/#{model_plural}/new"
      return link_to("<i class='fa fa-plus fa-lg'></i>".html_safe, path, html_options = {:class => "btn btn-#{size} btn-info", :title => I18n.t("#{model}.new.title")})
    end

    if action == "edit" then
      path = "/#{model_plural}/#{object.id}/edit"
      return link_to("<i class='fa fa-edit fa-lg'></i>".html_safe, path, html_options = {:class => "btn btn-#{size} btn-primary", :title => I18n.t("#{model}.edit.title")})
    end

    if action == "show" then
      path = "/#{model_plural}/#{object.id}"
      return link_to("<i class='fa fa-search-plus fa-lg'></i>".html_safe, path, html_options = {:class => "btn btn-#{size} btn-success", :title => I18n.t("#{model}.show.title")})
    end

    if action == "destroy" then
      path = "/#{model_plural}/#{object.id}"
      return link_to("<i class='fa fa-trash-o fa-lg'></i>".html_safe, path, html_options = {:class => "btn btn-#{size} btn-danger", :title => I18n.t("#{model}.destroy.title"), :data => { :confirm => t('.confirm', :default => t('helpers.links.confirm', :default => 'Are you sure?')) }, :method=> :delete})
    end
  end

  #POS functions
  def get_category_sidebar category
    if category[:parent].nil?
      content_tag(:li) {
        concat(link_to category[:name], "##{category[:id]}","data-toggle" => "tab", :role => "tab")
        get_subcategories(category) if !category[:submenucategories].nil?
      }
    end
  end

  def get_subcategories category
    concat(content_tag(:ul, class: ["nav", "nav-stacked"]) {
      subcategories = @menu_card[:menu_categories_variable_nil].select {|subcategory| subcategory[:parent]==category[:id]}
      subcategories.each do |subcategory|
        concat (content_tag(:li, class: ["nav", "nav-stacked"]) {
          concat(link_to subcategory[:name], "##{subcategory[:id]}","data-toggle" => "tab")
          get_subcategories subcategory if !subcategory[:submenucategories].nil? #Recursive call to get all sub-categories of this category
        })
      end
    })
  end

  def get_category_products category,menu_card
    _products = menu_card[:menu_products_variable_nil].select{|cat| cat[:menu_category_id]==category[:id].to_i}
    get_subcategory_products(category,menu_card,_products)
  end

  def get_subcategory_products(category,menu_card,products)
    if !category[:submenucategories].empty?
      subcategories = menu_card[:menu_categories_variable_nil].select {|subcategory| subcategory[:parent]==category[:id]}
      subcategories.each do |subcategory|
        _products = menu_card[:menu_products_variable_nil].select{|cat| cat[:menu_category_id]==subcategory[:id].to_i}
        products += _products
        get_subcategory_products(subcategory,menu_card,products)
      end
    end
    return products
  end

  def get_root_url
    root_url = root_url
    if can? :welcome, Home
      root_url = root_url
    elsif can? :index, Order
      root_url = orders_path  
    elsif can? :index, Bill
      root_url = bills_path
    elsif can? :index, Store
      root_url = stores_path  
    elsif can? :index, Vehicle
      root_url =  vehicles_path    
    elsif can? :index, DeliveryBoy
      root_url = delivery_boys_path  
    elsif can? :index, ReportFolder
      root_url = sale_reports_path
    end  
    return root_url  
  end

  def get_default_product(product)
    if product[:variants].empty?
      return product
    else
      product[:variants].each do |variant|
        if variant[:isdefault] == 1
          return variant
        end
      end
    end
  end

  def full_name(user_id)
    user = User.find(user_id)
    profile = user.profile
    return profile.firstname+" "+profile.lastname
  end

  def resource_product_current_stock(resource_id,product_id)
    current_stock = ResourceProductStock.where("resource_id=? AND product_id=?",resource_id,product_id).last
    if current_stock.present?
      current_stock = current_stock.stock
    else
      current_stock = 0
    end    
    return current_stock
  end

  def get_orders_count_of_customer(customer)
    if customer.bills.present?
      customer_array = Array.new()
      customer.bills.map { |bill| bill.orders.map{|order| customer_array.push order}}
      count = customer_array.count
    else
      count = 0
    end    
  end

  def get_total_bill_amount_by_date(customer,from_datetime,to_datetime,unit_id)
    bills = Bill.unit_bills(unit_id).valid_bill.by_recorded_at(from_datetime,to_datetime).by_customer(customer.id)
    if bills.present?
      amount = 0
      bills.each do |bill|
        amount += bill.grand_total
      end
    else
      amount = 0
    end 
    return amount
  end

  def get_total_bill_amount(customer)
    if customer.bills.present?
      amount = 0
      customer.bills.each do |bill|
        amount += bill.grand_total
      end
    else
      amount = 0
    end 
    return amount
  end

  # Calculating distance by lat long
  def calculate_distance_by_lat_long source_location, destination_location
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm                    # Radius in kilometers

    dlat_rad = (destination_location[0]-source_location[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (destination_location[1]-source_location[1]) * rad_per_deg

    lat1_rad, lon1_rad = source_location.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = destination_location.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c # Delta in kilometers
  end

  ###############global method to  get the resource associates with a user###############
  def resource_id_list_by_user(user_id)
    resource_id_list=[]
    search_in_area = Area.where("user_id=?",user_id).first
    if search_in_area.present?
      search_in_area.zones.each do |zone| 
        resource_id_list = resource_from_zone(zone,resource_id_list)
      end
    else
      search_in_zone = Zone.where("user_id=?",user_id).first
      if search_in_zone.present?
        resource_id_list = resource_from_zone(search_in_zone,resource_id_list)
      else
        resource_id_list=resource_for_sale_person(user_id,resource_id_list)
      end
    end
    resource = Resource.where("id In (?)",resource_id_list)
    return resource
  end

  #fetch final resources from bit_resources tble
  def resource_from_zone(zone_object,resource_id_list)
    zone_object.bits.each do |bit|
      resource_id_list += bit.bit_resources.pluck(:resource_id)
    end
    return resource_id_list
  end

  #fetch resources from user_resource pr user_bit if the user is a sale person
  
  def resource_for_sale_person(user_id,resource_id_list)
    if AppConfiguration.get_config_value("bit_wise_resource_allocation") == "enabled"
      search_in_user_bits = UserBit.where("user_id=?",user_id).uniq
      search_in_user_bits.each do |user_bit|
        resource_id_list += user_bit.bit.bit_resources.pluck(:resource_id)
      end
    else
      resource_id_list+= UserResource.where("user_id=?",user_id).uniq.pluck(:resource_id)
    end
    return resource_id_list
  end
  def is_assigned_to_zone_or_area(user_id)
    return Zone.where("user_id=?",user_id).present? ? true : Area.where("user_id=?",user_id).present? ? true : false
  end

  
  #helper method to get user_resources for an user 
  def get_user_resources(user_id,unit_id=nil,from_date=nil,to_date=nil)
  	puts "getting user resources"
    puts "from date: #{from_date}" if from_date.present?
    user = User.find(user_id)
    has_child = User.has_child(user.id)
    resource_id_list=[]
    if current_user.role.name == "owner"
      resources = Resource.by_unit(unit_id) 
    elsif has_child
      sale_persons  = get_sale_persons_for_user(user_id,user_list=[])
      if from_date.present? && to_date.present?
        resource_id_list = UserResource.where("user_id IN (?)",sale_persons).by_date_range(from_date,to_date).pluck(:resource_id).uniq
      else
        resource_id_list = UserResource.where("user_id IN (?)",sale_persons).pluck(:resource_id).uniq
      end
      resources = Resource.where("id IN (?)",resource_id_list)
    else
      resource_id_list = UserResource.where("user_id=?",current_user.id).pluck(:resource_id).uniq
      resources = Resource.where("id IN (?)",resource_id_list)
    end
    return resources
  end
  
  def get_sale_persons_for_user(user_id,user_list)
    child_users = User.user_children(user_id)
    if child_users.present?
      child_users.each do |cu|
        if User.has_child(cu.id)
          user_list =get_sale_persons_for_user(cu.id,user_list)
        else
          user_list.push cu.id #push the sale person id
        end
      end
    end
    return user_list
  end

  #to get the reason codes 
  def get_reason_codes(model_name, action_name)
    master_model = MasterModel.where("name=?",model_name).first
    reasons = []
    if master_model.present?
      model_actions = ModelAction.where("master_model_id=? AND name=?",master_model.id,action_name).first
      if model_actions.present?
        reasons = model_actions.reason_codes
      end
    end
    return reasons
  end
  
  #to get the chind units
  def child_units(unit_arr,unit_obj) # for the first call unit_arr=[]
    if unit_obj.children.present?
      unit_arr.concat(unit_obj.children.pluck(:id))
      unit_obj.children.each do |unit|
        child_units(unit_arr,unit)
      end
    end
    return unit_arr
  end
  
  def nested_child_users(parent_user_obj,user_obj_arr=[])
    if parent_user_obj.child_users.present?
      child_users = parent_user_obj.child_users
      user_obj_arr.concat(child_users)
      child_users.each do |user|
        nested_child_users(user,user_obj_arr)
      end
    end
    return user_obj_arr
  end
  
end