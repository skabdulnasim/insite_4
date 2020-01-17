require 'sidekiq/web'

#--- multitanent

class SubdomainPresent
  def self.matches?(request)
    request.subdomain.present?
  end
end

#-----------

Inventory::Application.routes.draw do

  resources :thirdparty_callbacks, only: [:index] do
    collection do
      
    end
  end

  resources :tag_groups
  resources :comprehensive_sale_reports, only: [:index] do
    collection do
      get 'bill_by_bill_report'
    end
  end

  resources :tag_groups

  resources :doc_types

  resources :check_informations

  resources :combo_items

  resources :addons_groups

  resources :proformas do
    collection do
      get 'fetch_orders'
    end
  end

  resources :financial_accounts do
    collection do
      get 'account_details'
    end
  end

  resources :incentive_rules
  resources :labels
  resources :areas do
    collection do
      get 'fetch_users'
    end
  end
  resources :zones do 
    collection do
      get 'fetch_users'
    end
  end
  resources :resource_order_history_details


  resources :resource_order_histories


  resources :user_targets


  resources :boxings

  resources :tags do
    collection do
      post "update_status"
    end
  end

  resources :packages do
    collection do
      get 'search_package_components'
    end
  end

  resources :model_actions

  resources :actions

  resources :reason_codes

  resources :master_models

  resources :cost_categories

  resources :money_refunds

  resources :return_policies do
    collection do
      post 'delete_return_cause'
    end
  end

  resources :cancelation_policies do
    collection do
      post 'delete_cancelation_cause'
    end
  end


  resources :vendor_product_prices do
    collection do
      post 'update_status'
    end
  end

  resources :delivery_charges

  resources :questions do 
    collection do
      post 'update_status'
    end
  end

  resources :customer_states do 
    collection do 
      post "update_status"
    end
  end
  resources :inventory_dashboards, only: [:index]
  resources :customer_statuses
  resources :user_work_statuses
  resources :visiting_histories
  resources :upi_merchants
  resources :resource_product_stocks
  resources :payment_wallets
  resources :inspections
  resources :bill_destinations
  resources :item_preferences
  resources :menu_mappings
  post "/menu_mappings/:id/update_status", to: 'menu_mappings#update_status', as: 'menu_mapping_update_status'
  resources :days
  resources :sizes
  resources :colors
  resources :sale_rules do
    collection do
      get 'all_sale_rules'
    end
  end
  resources :sales_persons do
    collection do
      post 'allot_resource'
      post 'allot_resource_map'
      post "delete_user_resource"
      post "import"
      get "get_allocations"
      post "create_allocation"
      post "remove_allocation"
      post "update_allocation"
      post "create_recursive_allocation"
      get "sample_csv"
      post "remove_all_by_date"
    end  
  end  
  match '/paytm_payment' => 'paytm#start_payment', via: [:post], :as => :paytm_payment
  match '/confirm_payment' => 'paytm#verify_payment', via: [:post]

  resources :product_religions
  resources :allergies
  resources :parties
  resources :customer_queue_states
  get "outlet_types/save"
  resources :outlet_types
  get "more_infos/save"
  resources :more_infos
  resources :unit_images
  resources :quotations
  resources :customers do
    collection do
      post '/import',to: "customers#import", as: "import"
      get 'find'
      get 'find_by_login'
    end
    resources :addresses
    resources :customer_profiles
    resources :addresses
  end
  resources :otps
  resources :own_customers do
    resources :own_customer_addresses
  end
  resources :process_compositions
  resources :production_processes do
    member do
      put '/toggle_trash', to: "production_processes#toggle_trash", as: "toggle_trash"
    end
  end
  resources :own_customers do
    resources :own_customer_addresses
  end
  resources :denominations
  resources :countries
  resources :cash_outs
  resources :cash_ins
  resources :cash_handlings
  resources :percentages
  resources :conjugated_units
  resources :stock_purchase_payments, only: [:create]
  resources :news_event_galleries
  resources :feedback_options
  resources :feedbacks
  resources :news_events
  resources :resource_states
  resources :onboarding do
    collection do
      post  '/import',   to: "onboarding#import", as: "import"
    end
  end
  resources :onboarding, only: [:show]
  resources :media
  resources :developer_apps
  resources :buffet_rules, except: [:destroy, :edit, :update]
  resources :buffet_groups, except: [:destroy]
  resources :product_attribute_groups
  resources :product_attribute_sets do
    collection do
      get 'seed'
    end
  end
  resources :product_attribute_keys
  resources :product_attribute_options
  # resources :attendances,except: [:show, :update, :edit]
  resources :reservations do
    collection do
      get :reservations_list
    end  
  end  
  resources :availabilities
  resources :slots
  resources :resources do
    collection do
      get 'fetch_active_menu_cards'
      get 'get_resources'
      post 'change_resource_state'
      post 'swap_resource'
      get 'retail_shops_list'
      get 'export_resource'
      post '/import',   to: "resources#import", as: "import"
      post '/import_commission', to: "resources#import_commission", as:"import_commission"
      post '/import_beneficiary', to: "resources#import_beneficiary", as:"import_beneficiary"
      get 'sample_commission_csv'
      get 'find'
      get 'fetch_section_resources'
      get 'fetch_active_menu_products'
    end
    resources :commission_rules
    resources :beneficiaries
  end
  resources :commission_rules do
    collection do
      post "quick_update"
    end
  end
  resources :resource_types
  resources :beneficiaries
  #get "customer_queues/index"

  resources :customer_queues

  resources :lots, only: [:show] do
    collection do
      put "delete_lot_sale_rule"
      put "lot_quick_update"
    end
  end
  resources :delivery_reports, only: [:index] do 
    collection do 
      get "slot_specific_delivery_reports"
      get "delivery_boys_report"
    end
  end
  mount Rscratch::Engine => '/rscratch'
  resources :reprint_details,only: [:index]

  # API V2 routes

  namespace :api, defaults: {format: 'json'} do
    namespace :v2 do
      resources :doc_types
      resources :check_informations, only: [:index, :update, :show] do
        collection do 
        end  
      end 
      resources :financial_accounts
      resources :customer_product_wishlists do
        collection do
          post 'remove_product'
        end  
      end  
      resources :financial_accounts_transactions do
        collection do 
          post 'debit'
        end  
      end  
      resources :proformas
      resources :boxings, only: [:create, :update, :show] do
        collection do
          post 'search_by_barcode'
          post 'create_box'
          post 'create_box_item'
          post 'remove_box_item'
        end
      end
      resources :reason_codes, only: [:index] do
        collection do
          get 'master_models'
          get 'model_actions'
        end
      end
      resources :warehouses do 
        collection do 
          post 'put_product'
          post 'pick_product'
          get 'product_bins'
          get 'bin_product_quantity'
        end
      end
      resources :packages do 
        collection do 
          get 'required_product_fields'
          post 'add_product'
          post 'package_creation'
          post 'edit_package_name'
          post 'create_package_unit'
          post 'edit_package_unit'
          post 'add_package_unit_product'
          post 'add_product_composition'
          get 'package_details'
          post 'add_package_component'
          get 'package_component_details'
          post 'remove_package_unit'
          post 'remove_package_unit_product'
        end
      end
      resources :cost_categories
      resources :beneficiaries, only: [:index]
      resources :labels, only: [:index]
      resources :return_items, only: [:index, :update]
      resources :questions, only: [:index, :show]
      resources :return_item_reports
      resources :user_login_logouts
      resources :delivery_addresses
      resources :bill_reprints, only: [:index, :create, :show]
      resources :user_work_statuses, only: [:create] do
        collection do
          get "work_statuses"
        end  
      end  
      resources :customer_communications, only: [:create] do
        collection do
          get "communications"
        end
      end
      resources :customer_tags, only: [:index,:create]
      resources :customer_notes, only: [:index,:create] do 
        collection do 
          get "notes"
        end
      end
      resources :resource_product_stocks, only: [:create]
      resources :visiting_histories, only: [:create, :index, :show]
      resources :item_preferences, only: [:index]
      resources :bill_destinations, only: [:index]
      resources :upi_merchants, only: [:index]
      resources :delivery_boys do
        collection do
          post "sign_in"
        end
      end
      resources :quotations
      resources :configurations, only: [:index]
      resources :days, only: [:index] do
        collection do
          get "menu_mapping"
        end  
      end
      resources :offers , only: [:index] do
        collection do
          post 'get_offers'
        end
      end 
      resources :units, only: [:index, :show] do
        collection do
          get "get_units"
          get "units_sales_persons"
        end  
      end  
      resources :sections, only: [:show] do
        collection do
          get 'section_tax_groups'
        end
      end
      resources :menu_cards, only: [:index, :show] do
        collection do
          get 'mp_sale_rules'
          get 'download_menu_cards'
        end
        member do
          get "product/:product_id", to: "menu_cards#product"
        end
      end
      resources :boutique_capillaries do
        collection do
          get "customer_search"
          post "customer_add"
          post "customer_profile_update"
          post "regular_transaction_add"
          post "loyality_bill_full_return"
          post "loyality_bill_amount_return"
          post "loyality_bill_line_item_return"
          post "non_loyality_bill_return"
          post "non_loyality_amount_return"
          post "non_loyality_line_item_return"
          get "validation_code"
          post "point_redeem"
          get "check_coupon"
          post "coupon_redeem"
        end
      end
      resources :paytm do
        collection do
          get "get_checksum"
          post "start_payment"
          post "verify_payment"
        end
      end

      resources :stock_audits, only: [:index, :update]

      resources :promotions, only: [:index] do
        collection do
          get "verify_promo"
        end
      end
      resources :coupons, only: [:index] do
        collection do
          get "verify_coupon"
        end
      end
      resources :tables, only: [:index,:update] do
        collection do
          post "swap_table"
        end
      end
      resources :orders, only: [:index, :create, :update, :show] do
        collection do
          post "cancel_item"
          post "verify_deliverable_otp"
          post "resend_deliverable_otp"
        end
      end

      # resources :external_orders, only: [:index, :show, :create, :update] do
      resources :external_orders, only: [:index, :create, :update] do
        collection do
          post "set_status"
        end
      end
      resources :thirdparty_callbacks, only: [:create, :show] do
        collection do
          
        end
      end
      resources :resource_order_histories, only: [:index, :create, :show]
      resources :zomato_external_orders, only: [:create]
      resources :bills, only: [:index, :show, :create, :update] do
        collection do
          get "find_bill_by_serial"
          put "bill_on_hold"
        end
      end  
      
      resources :customer_states,only:[:index] do
      end

      resources :tags, only: [:index] do
      end
      resources :customer_state_transitions, only: [:index,:create,:show] do
      end
      resources :settlements, only: [:create]
      resources :customers, only: [:show, :create, :update] do
        collection do
          post "login"
          post "find_by_login"
          post "add_address"
          get "forgot_password"
          put "reset_password"
          post "search_by_customer_name"
          post "login_by_otp"
          post "verify_otp"
          post "add_financial_account"
          get "account_transaction_history"
        end
        member do
          put "change_password"
        end  
      end

      resources :approvals do
        collection do
          post "update_approval"
        end
      end

      resources :own_customers, only: [:create, :update] do
        collection do
          get "find_by_identifications"
          post "customer_queues"
          get "queue_index"
          put "update_customer_queues"
        end
      end 
      resources :customer_queues, only: [:index, :create, :update, :show]
      resources :users, only: [:index,:show,:destroy] do
        collection do
          post "login"
          post "logout"
          post "verify_license"
          post "create_live_map_points"
          get  "get_user_incentive"
          get "user_group_data"
          get "get_users_by_role"
        end
      end
      resources :lots, only: [:index, :show] do
        collection do
          get "download_lots"
        end  
      end  
      resources :vendors, only: [:index, :show, :create, :update] do
        collection do
          get 'vendor_pjp'
          post 'allocate_vendor_products'
          post 'vendor_contract_details'
        end
      end
      resources :loyalty_purchases, only: [:create]
      resources :loyalty_cards, only: [:show] do
        collection do
          get :find_by_mobile_no
        end  
      end  
      resources :stocks, only: [:index] do
        collection do
          get :get_all_product_stocks
          get :get_business_type
          get :in_out_stock
        end  
      end  
      resources :stock_transfers, only: [:index, :update, :create] do
        collection do
          post :get_est_price
        end  
      end
      resources :store_requisitions, only: [:create] do
        collection do
          get :get_requistion_deta
          get :received_requisition
          get :send_requisition_log
          put :update_requisition_state
          get :summary_requisition
          get :get_summary_details
          post :create_send
        end
      end

      resources :purchase_orders, only: [:index, :create, :show] do
        collection do
          get :approval_show
        end
      end
      
      resources :vehicles, only: [:index] do
        collection do
          get :get_pickup_packages
          put :update_shipment_status
        end 
      end 
      resources :order_details, only: [:update]
      resources :stock_purchases, only: [:index, :update] do
        collection do
          get :get_payment_details
          get :generate_stock_receive_row
        end  
      end  
      resources :stock_audits, only: [:index, :update]

      resources :reports, only: [:get_dashboard_data] do
        collection do
          get :get_dashboard_data
          get :get_bill_report
          get :get_item_report
          get :get_product_sales
          get :get_bill_details
        end
      end
      resources :denominations, only: [:index]
      
      resources :cash_handlings, only: [:index, :show] do
          collection do 
            post "cash_in"
            post "cash_out"
          end
      end
      resources :resources, only: [:index, :update] do
        collection do
          get :get_available_resource
          post :swap_resource
          get :resource_pjp
          get :by_unique_identity_no
          get :resource_group_data
        end  
      end  
      resources :slots, only: [:index] do
        collection do
          get :get_available_slot
          get :get_resource_slot
          get :get_available_order_slot
        end  
      end  
      resources :stock_predictions do
        collection do
          get :get_stocks_transfer_details
          get :get_product_composition
        end  
      end 
      resources :reservations, only: [:index, :create, :update, :show] do
        collection do
          put "cancel_reservation"
          put "swap_reservation"
        end  
      end  
      resources :resource_types, only: [:index]
      resources :resource_states, only: [:index]
      resources :advertisements, only: [:index]
      resources :news_events, only: [:index]
      resources :feedbacks, only: [:index]
      resources :products, only: [:index,:show] do
        collection do
          get :get_colors_sizes
        end  
      end  
      resources :otps, only: [:create, :update] do
        collection do
          put "resend"
        end
      end
      resources :parties
      resources :guests
      resources :preauths, only: [:create] do
        collection do
          get "check_availability"
        end  
      end  
      resources :paypals do
        collection do
          get "client_token"
          post "checkout"
        end  
      end  
      resources :sale_rules, only: [:index]
      resources :customer_feedbacks, only: [:create] 
      resources :production_processes, only: [:index]
      resources :stock_productions, only: [:create] do
        collection do
          get 'get_products'
        end
        member do 
          get 'show'
        end
      end
      resources :payment_wallets, only: [:index]
      resources :stores do
        collection do
          get 'find_by_pincode'
          get 'store_products'
        end 
      end
      resources :colors, only: [:index]
      resources :sizes, only: [:index]
      resources :inspections, only: [:create,:show]
      post 'wallets/:identity', to: 'wallets#credit'
      get 'wallets/:identity', to: 'wallets#show'
      resources :knowlarities, only: [:index] do
        collection do 
          post 'knowlarity_call_log'
          get 'fetch_current_knowlarity_customer'
        end
      end
      resources :urbanpipers do
        collection do
          post "customer_register"
          get "customer_search"
          put "customer_profile_update"
          post "wallet_transaction"
          post "processing_purchase"
          get "reward_redemption"
        end
      end
      
    end
  end

  resources :dashboards, only: [:index] do
    collection do
      get :sales
      get :inventory
      get :analytics
    end
  end
  resources :loyalty_card_payments
  resources :loyalty_purchases
  resources :loyalty_card_classes
  resources :loyalty_card_transactions
  resources :loyalty_cards
  resources :rooms
  resources :third_party_payment_options
  resources :alpha_promotions
  resources :product_basic_units
  #mount DealMaker::Engine => "/deal_maker"
  resources :pos_terminals do
    collection do
      # post :verify_customer
      # post :register_customer
      get :tally_exporter
      get :page
      get :file
    end
    member do
      get :find_product
      get :find_barcode
    end
  end

  resources :return_items, only: [:create] do
    collection do
      post 'add_item_to_stock', to: "return_items#add_item_to_stock", as: "add_to_stock"
      get 'show_stores', to: "return_items#show_stores", as: "show_stores"
      post 'add_return_item_to_stock', to: "return_items#add_return_item_to_stock", as: "add_return_item_to_stock"
    end
  end

  resources :advertisements do
    resources :advertisement_galleries
    collection do
      post :remove_pic
    end
  end
  resources :denominations, only: [:index]
  
  resources :cash_handlings, only: [:index, :show] do
    collection do 
      post "cash_in"
      post "cash_out"
    end
  end

  #get "sessions/new"
  #get    'delivery_boy_login'   => 'sessions#new'
  post   'delivery_boy_login'   => 'sessions#create'
  resources :delivery_boys do
    member do
      get :assign_unit
      post :create_assign_unit

    end
    collection do
      post :sign_in
      get :assign_order
      get :assign_return
      post "create_assign_order", to: "delivery_boys#create_assign_order"
      post "create_assign_return", to: "delivery_boys#create_assign_return"
      post "cancel_assigned_order/:data", to: "delivery_boys#cancel_assigned_order"
      get :fetch_order_data
      post "cancel_assigned_return"
    end
  end

  resources :notifications do
    collection do
      get :stock_expiry_alerts
      get :thresh_hold_alerts
      get :approval_alerts
    end
  end
  resources :table_reservations,except: [:show] do
    collection do
      get "get_tables_list/:section_id", to: "table_reservations#get_tables_list"
      post "meta_data_cust/:reservation_id", to: "table_reservations#meta_data_create_cust_view"
      post "meta_data_table", to: "table_reservations#meta_data_create_table_view"
      get "reservation_list/:date", to: "table_reservations#reservation_list"
      get "customer_details"
      post "allot_table"
      post "table_reservation_create"
    end
  end

  resources :user_role_reports, only: [:index] do
    collection do
      get 'role_permission', to: "user_role_reports#index"
    end
  end

  resources :incentive_reports, only: [:index] do
    collection do
      get 'by_target', to: "incentive_reports#by_target"
    end
  end

  resources :sale_reports, only: [:index] do
    collection do
      get 'by_date', to: "sale_reports#by_date", as: "by_date"
      get 'by_date_range', to: "sale_reports#by_date_range", as: "by_date_range"
      get 'day_wise_tax_report', to: "sale_reports#day_wise_tax_report", as: "day_wise_tax_report"
      get 'sale_summery', to: "sale_reports#sale_summery", as: "sale_summery"
      get 'category_wise', to: "sale_reports#category_wise", as: "category_wise"
      get 'sku_wise', to: "sale_reports#sku_wise", as: "sku_wise"
      get 'time_interval_wise', to: "sale_reports#time_interval_wise", as: "time_interval_wise"
      get 'sale_user_wise', to: "sale_reports#sale_user_wise", as: "sale_user_wise"
      post 'save_report_preferences', to: "sale_reports#save_report_preferences", as: "save_report_preferences"
      get 'by_date_boh', to: "sale_reports#by_date_boh", as:"by_date_boh"
      get 'by_date_cod', to: "sale_reports#by_date_cod", as:"by_date_cod"
      get 'adons_sales_reports'
    end
  end

  resources :customer_reports, only: [:index] do
    collection do
      get 'customer_details', to: "customer_reports#customer_details", as: "customer_details"
      get 'by_date_customer_details', to: "customer_reports#by_date_customer_details", as: "by_date_customer_details"
    end
  end

  resources :se_reports, only:[:index] do
    collection do
      get 'by_date_range', to: "se_reports#by_date_range", as: "by_date_range"
      get 'by_date_product_pricing', to: "se_reports#by_date_product_pricing", as: "by_date_product_pricing"
    end
  end

  resources :tsp_reports, only:[:index] do
    collection do
      get 'by_date_range', to: "tsp_reports#by_date_range", as: "by_date_range"
      get 'day_by_day_order_reports', to: "tsp_reports#day_by_day_order_reports", as: "day_by_day_order_reports"
      get 'day_by_day_shop_order_report', to: "tsp_reports#day_by_day_shop_order_report", as: "day_by_day_shop_order_report"
      get 'shop_wise_order_summary_report', to: "tsp_reports#shop_wise_order_summary_report", as: "shop_wise_order_summary_report"
      get 'shop_sumary_report', to: "tsp_reports#shop_sumary_report", as: "shop_sumary_report"
      get 'tse_sumary_report', to: "tsp_reports#tse_sumary_report", as: "tse_sumary_report"
      get 'shop_database', to: "tsp_reports#shop_database", as: "shop_database"
      get 'shop_commission_report', to: "tsp_reports#shop_commission_report", as: "shop_commission_report"
      get 'beneficiary_report'
      get 'invoice_upload_report'
      get "tse_sales_report"
      get 'shop_wise_sales_report'
      get "plant_wise_dispatch_report"
      get "sale_person_target_report"
      get "shop_target_report"
      get "district_wise_sales_report"
    end  
  end  

  resources :runner_reports, only:[:index] do
    collection do
      get 'by_date_range_delivery', to: "runner_reports#by_date_range_delivery", as: "by_date_range_delivery"
      get 'return_pickup_details'
    end  
  end  

  resources :nc_report, only: [:index] do
    collection do
      get 'by_date', to: "nc_report#by_date", as: "by_date"
      get 'by_date_range', to: "nc_report#by_date_range", as: "by_date_range"
      get 'category_wise', to: "nc_report#category_wise", as: "category_wise"
      get 'table_wise', to: "nc_report#table_wise", as: "table_wise"
      post 'save_report_preferences', to: "nc_report#save_report_preferences", as: "save_report_preferences"
    end
  end

  resources :void_reports, only: [:index] do
    collection do
      get 'by_date', to: "void_reports#by_date", as: "by_date"
    end
  end

  resources :inventory_reports, only: [:index] do
    collection do
      get 'cost_of_material_report'
      get 'store_stocks', to: "inventory_reports#store_stocks", as: "store_stocks"
      get 'stock_transfer', to: "inventory_reports#stock_transfer", as: "stock_transfer"
      get 'pending_stock_receive', to: "inventory_reports#pending_stock_receive", as: "pending_stock_receive"
      get 'stock_purchase', to: "inventory_reports#stock_purchase", as: "stock_purchase"
      get 'stock_consumption', to: "inventory_reports#stock_consumption", as: "stock_consumption"
      get 'store_indent', to: "inventory_reports#store_indent", as: "store_indent"
      get 'stock_audit', to: "inventory_reports#stock_audit", as: "stock_audit"
      get 'stock_in_hand', to: "inventory_reports#stock_in_hand", as: "stock_in_hand"
      get 'stock_in_store', to: "inventory_reports#stock_in_store", as: "stock_in_store"
      get 'stock_movement', to: "inventory_reports#stock_movement", as: "stock_movement"
      get 'stock_issue', to: "inventory_reports#stock_issue", as: "stock_issue"
      get 'avaliable_stock', to: "inventory_reports#avaliable_stock", as: "avaliable_stock"
      get 'avaliable_stock_for_period', to: "inventory_reports#avaliable_stock_for_period", as: "avaliable_stock_for_period"
      get 'unit_wise_stock_transfer', to: "inventory_reports#unit_wise_stock_transfer", as: "unit_wise_stock_transfer"
      get 'unit_wise_stock_purchase', to: "inventory_reports#unit_wise_stock_purchase", as: "unit_wise_stock_purchase"
      get 'unit_wise_stock_purchase_summary', to: "inventory_reports#unit_wise_stock_purchase_summary", as: "unit_wise_stock_purchase_summary"
      get 'unit_wise_stock_transfer_summary', to: "inventory_reports#unit_wise_stock_transfer_summary", as: "unit_wise_stock_transfer_summary"
      post 'save_report_preferences', to: "inventory_reports#save_report_preferences", as: "save_report_preferences"
      get 'raw_product_consumption', to: "inventory_reports#raw_product_consumption", as: "raw_product_consumption"
      get 'stock_expiry_report'
      get 'unit_wise_stock_summary', to: "inventory_reports#unit_wise_stock_summary", as: "unit_wise_stock_summary"
      get 'vendor_payment', to: "inventory_reports#vendor_payment", as: "vendor_payment"
      get 'vendor_products',to: "inventory_reports#vendor_products", as: "vendor_products"
      get "stock_thresh_hold", to: "inventory_reports#stock_thresh_hold", as: "stock_thresh_hold"
      get 'vendor_wise_product_sale', to: "inventory_reports#vendor_wise_product_sale", as: 'vendor_wise_product_sale'
      get 'stock_aging_report'
      get 'store_simo_report'
    end
  end

  resources :boh_reports, only: [:index] do
    collection do
      get 'by_date_boh', to: "boh_reports#by_date_boh", as:"by_date_boh" 
    end  
  end  

  resources :settlement_reports, only: [:index] do
    collection do
      get 'card_wise', to: "settlement_reports#card_wise", as: "card_wise"
      get 'loyalty_card_wise', to: "settlement_reports#loyalty_card_wise", as: "loyalty_card_wise"
    end
  end

  resources :loyalty_reports, only: [:index] do
    collection do
      get 'by_date', to: "loyalty_reports#by_date", as: "by_date"
      get 'loyalty_point_use', to: "loyalty_reports#loyalty_point_use", as: "loyalty_point_use"
      get 'membership_points_accumulation', to: "loyalty_reports#membership_points_accumulation", as: "membership_points_accumulation"
    end
  end

  resources :reports, only: [:get_bill_wise_report] do
    collection do
      get 'get_bill_wise_report',      to: "reports#get_bill_wise_report", as: "get_bill_wise"
      get 'get_category_wise_report',  to: "reports#get_category_wise_report", as: "get_category_wise"
    end
  end

  resources :kot_reports, only: [:index] do
    collection do
      get 'void_kot_report',  to: "kot_reports#void_kot_report", as: "void_kot_report"
    end
  end

  resources :reservation_reports, only:[:index] do
    collection do
      get 'reservation_report', to: "reservation_reports#reservation_report", as: "reservation_report"
    end  
  end 

  resources :return_item_reports, only: [:index] do
    collection do
      get 'by_date'
      get 'refund_report'
    end
  end

  resources :user_login_logouts, only: [:index] do
    collection do 
      get 'by_date'
    end
  end
  
  resources :order_reports, only: [:index] do
    collection do
      get 'home_delivery_order_reports'
      get 'order_count_reports'
    end
  end

  resources :report_folders, except:[:show] do
    collection do
      get 'select_relation/:master_model', to: "report_folders#select_relation", as: "select_relation"
    end
    resources :reports, except: [:edit, :update ]
    resources :custom_reports
    resources :reports, only: [:customize] do
      member do
        get     'customize',                 to: "reports#customize"
        get     'customize/step/:step_id',   to: "reports#customize", as: "customize_step"
        post    'customize/step/:step_id',   to: "reports#customize"
        #post    'customize/:step_id',   to: "report_templates#customize"
        #post    'customize/:step_id',   to: "report_templates#customize"
      end
    end
  end

  get 'report_folders/attributes_accessible/:id',to: "report_folders#attributes_accessible", as: 'attributes_accessible'
  post 'report_folders/attributes_accessible/:id',to: "report_folders#attributes_accessible"
  #post "report_folders/update_order"
  get '/printers/model_data_list/:printer_id/:model_name', to: "printers#model_data_list"
  resources :printers, except: [:show, :new, :index] do
    collection do
      post 'exchange_ip'
    end
  end

  resources :tax_groups do
    collection do
      get 'save_tax_groups_tax_classes'
    end
  end

  resources :sorts do
    collection do
      get 'get_order_details'
      get 'get_order_by_id'
    end
  end

  resources :accounts
  resources :cashes
  resources :coupons
  resources :cards
  resources :payments
  resources :settlements
    post "notifications/create"
  get "notifications/events"
  # resources :notifications, except:[:show] do
  #   collection do
  #     get :events
  #   end
  # end

  ############ New routes for inventory ############
  resources :warehouse_meta do
    collection do
      get "racks"
    end
  end
  resources :stores do
    resources :warehouse_meta, only:[:index,:new,:create, :destroy]
    resources :boxings, only: [:show, :new, :update, :index]
    resources :store_racks,only: [:index, :new, :create]
    resources :return_items, only: [:index, :show]
    member do
      get  'add_products',   to: "stores#add_products", as: "add_products"
      post "allocate_product"
    end
    get 'reports', on: :member
    get 'kitchen_store', on: :member
    get 'return_store', on: :member
    resources :stocks, only: [:index, :show] do
      get '/:product_id', to: 'stocks#index', on: :collection
      get '/by_sku/:sku', to: 'stocks#by_sku', on: :collection
      get '/barcode/:id', to: 'stocks#barcode', on: :collection
    end
    resources :stock_purchases, only: [:show, :update, :create] do
      member do
        get 'barcodes'
        get 'edit_stock_purchase'
      end
    end
    resources :store_requisitions, only: [:index, :show, :new] do
      get '/requisition_summary', to: 'store_requisitions#requisition_summary', on: :collection
    end
    resources :purchase_orders do
      get '/new/:vendor_id', to: 'purchase_orders#new', on: :collection
      get '/product_vendors', to: 'purchase_orders#product_vendors', on: :collection
      get 'cancel_po', to: 'purchase_orders#cancel_po', on: :collection
    end
    resources :stock_productions, only: [:new, :create, :show, :update] do
      collection do
        put 'stock_production_meta_process_update'
        put 'stock_production_meta_process_width_update'
        get 'get_production_status'
      end
    end
    resources :kitchen_production_audits, only: [:new] do
      get '/serial/:audit_id', to: 'kitchen_production_audits#show', on: :collection
      collection do
        post 'update_audit'
        post 'approve_audit'
      end
    end
    resources :simos, only: [:show, :new, :update] do
      member do
        post  '/toggle_trash',   to: "simos#toggle_trash", as: "toggle_trash"
      end 
    end

    resources :stock_audits do
      collection do
        post 'audit_options'
      end
      resources :steps, :controller=>"stock_audit_steps"
    end
    resources :stock_transfers, except:[:index, :edit, :destroy] do
      get '/new/:transfer_type', to: 'stock_transfers#new', on: :collection
      get '/:stock_transfer_id/generate_invoice/:invoice_name', to: 'stock_transfers#generate_invoice', on: :collection
      collection do
        post 'transfer_options'
        post 'custom_create_for_requistion'
        post 'custom_create_for_boxing'
        get 'update_picked_quantity'
      end
      resources :steps, :controller=>"stock_transfer_steps"
    end
    resources :stock_transfer_templates, only: [:index, :destroy] do
      get '/:template_type', to: 'stock_transfer_templates#index', on: :collection
      member do
        get 'details'
      end
    end
    resources :purchase_order_steps
  end
  # resources :store_racks, only: [:show, :edit, :update, :destroy]
  resources :stores, shallow: true do
    resources :store_racks do
      resources :bins
    end
  end
  resources :stock_transfers do
    collection do
      post 'update_status'
      get :update_picked_quantity
    end
  end

  #resources :stock_purchases
  resources :stock_productions do
    collection do
      get 'check_process_dependency'
    end
  end

  resources :stocks do
    collection do
      put 'barcode_print_update'
    end
  end
  resources :vehicles
  resources :store_requisitions do
    collection do
      get 'copy_requisition'
      get 'get_summary_details'
      get 'send_requisition'
      get 'save_store_requisition'
      get 'get_requisition_details'
      get 'update_requisition_state'
    end
  end
  resources :store_requisition_meta
  resources :purchase_orders do
    collection do
      get "send_purchase_order"
      get "get_send_purchase_order_details"
      post  '/save_purchase_order',   to: "purchase_orders#save_purchase_order", as: "save_purchase_order"
      post 'save_pom'
      post 'remove_pom'
      post 'update_pom'
      get 'send_smart_po'
      post 'update_pomd'
      post 'remove_all_pomd'
      get 'vendor_product_price'
      post 'cancel_po_item'
    end
  end
  resources :purchase_order_meta
  resources :simos
  #----------------------***----------------------#

  resources :sections do
    collection do
      post "delete_thirdparty_configuration"
    end
  end

  resources :combinations_rules
  resources :combination_types
  apipie
  resources :order_statuses
  resources :order_details
  post "order_details/update_order_detail_status"
  # post "orders/update_order"

  get "orders/get_order_by_customer"
  get "orders/order_by_delivery_boy"
  get "orders/manage_settings"
  post "orders/trash"
  # post "orders/place_order"
  get "orders/cancel_order_product"
  post "orders/update_order_status"
  post "orders/update_order_state"
  get "orders/cancel_order"
  get "orders/issue_stock"
  resources :orders do
    collection do
      post "import"
      get "future_orders"
      post "/order_accumulation", to: "orders#order_accumulation", as: "order_accumulation"
      post "/urbanpiper_status", to: "orders#urbanpiper_status", as: "urbanpiper_status"
    end  
    member do
      post 'issue_stock'
    end  
  end  

  resources :bills, except:[:new, :destroy] do
    collection do
      post  'split_bill'
      get   'get_unsetteled_bills'
      get   'get_bill_by_serial'
    end
    member do
      get   'generate_bill'
    end
  end

  resources :table_types

  resources :table_states

  resources :tables do
    collection do
      get 'manage_settings'
      get 'get_tables'
      post 'change_table_state'
      post 'swap_table'
      # get 'reservation'
      # get 'floorplan'
      # get 'get_tables'
      # post 'check'
    end
  end

  #get "home/bulk_product_upload"

  #resources :app_configurations
  resources :app_configurations , :only => ['index', 'create', 'update'] do
    collection do
      get 'basic_configurations'
      get 'printers'
      post 'save_config'
      post 'update_account'
      get 'check_app_config'
    end
  end

  get "access_manager/index"
  put "access_manager/show"
  post "access_manager/update_capabilities"
  get "access_manager/settings"
  post "access_manager/show_settings"
  post "access_manager/save_settings"
  post "access_manager/update_settings"
  post "access_manager/create_role"
  put "access_manager/update_role"

  #get "home/download"
  #get "home/get_stock_details"
  get "home/get_products"
  get "home/unit_tree"
  get "home/get_product_stock"

  resources :snippets
  mount Sidekiq::Web, at: "/sidekiq"
  # authenticate :user do
  #   mount Sidekiq::Web => '/sidekiq'
  # end

  get "oops/index"

  get "api/restapi/index"
  post "api/restapi/upload_media"
  get "api/restapi/get_all_product_stocks"
  post "api/restapi/get_user_by_email"
  get "api/restapi/get_store_data"
  post "api/restapi/initiaize_product_transfer"
  post "api/restapi/recieve_shipment_products"
  get "api/restapi/get_all_product_stocks"
  get "api/restapi/get_all_product_stocks"
  get "api/restapi/get_store_delivering_stocks"
  get "api/restapi/get_pickup_packages"
  get "api/restapi/get_store_pending_pos"
  post "api/restapi/receive_po_items"
  post "api/restapi/update_shipment_status"
  post "api/restapi/get_stock_audit_debit_info"
  post "api/restapi/initiate_stock_audit"
  get "api/restapi/quick_reports"
  get "api/restapi/get_product_stock_details"
  get 'api/restapi/get_store_stocks'
  get "api/restapi/adsr_data_exposer"
  get "api/restapi/get_resources"
  get "api/restapi/get_slots"
  get "api/restapi/get_reservations"
  get "api/restapi/get_available_slot"
  get "api/restapi/get_menu_product"
  get "api/restapi/get_orders"

  resources :tax_classes

  resources :vendors do
    collection do
      get 'new_import'
      get 'get_selected_unittype'
      post  '/import',   to: "vendors#import", as: "import"
      post 'create_vendor'
    end
    member do
      get  '/add_vendor_products',   to: "vendors#add_vendor_products", as: "add_vendor_products"
      delete  'remove_vendor_product/:product_id',   to: "vendors#remove_vendor_product", as: "remove_vendor_product"
      post "allocate_product_to_vendor"
      get 'edit_vendor_product/:product_id', to: "vendors#edit_vendor_product", as: "edit_vendor_product"
      post 'update_vendor_product/:product_id', to: "vendors#update_vendor_product", as: "update_vendor_product"
      get 'payment_details'
      put 'update_vendor'
    end
  end

  #generic store stocks details route

  get "products/add_tax"
  post "products/product_unit_update"
  # get "products/get_revenue"

  resources :product_units

  resources :product_meta

  resources :unit_details

  get "type_of_cuisines/save"
  resources :type_of_cuisines

  get "atmospheres/save"
  resources :atmospheres

  get "form_of_payments/save"
  resources :form_of_payments

  # get "hl_home/index"

  get "menu_products/filter"
  get "menu_products/find_sub_menu_products"
  get "menu_products/mode_toggle"
  get "menu_products/copy_menu"
  get "menu_products/thirdparty_item_action"
  resources :menu_products do
    collection do
      post  '/thirdparty_upload',   to: "menu_products#thirdparty_upload", as: "thirdparty_upload"
      post  '/urbanpiper_item_toggle',   to: "menu_products#urbanpiper_item_toggle", as: "urbanpiper_item_toggle"
      post  '/urbanpiper_item_toggle_outlet',   to: "menu_products#urbanpiper_item_toggle_outlet", as: "urbanpiper_item_toggle_outlet"
      post  '/thirdparty_menu_toggle',   to: "menu_products#thirdparty_menu_toggle", as: "thirdparty_menu_toggle"
      post  '/import',   to: "menu_products#import", as: "import"
      put "delete_mp_sale_rule"
    end
    member do
      post "quick_update"
    end
  end

  resources :stock_purchases do
    collection do
      post  '/import',   to: "stock_purchases#import", as: "import"
      post 'cancel_stock_purchase'
    end
    # member do
    #   get 'edit_stock_purchase'
    # end
  end

  resources :menu_categories do
    collection do
      post  '/import',   to: "menu_categories#import", as: "import"
    end
  end

  get "menu_cards/master_mode_toggle"
  # get "menu_cards/create_and_copy_menu"
  post "/menu_cards/:id/trash", to: 'menu_cards#trash', as: 'menu_card_trash'
  #post "menu_cards/trash"
  get "menu_cards/manage_settings"
  get "menu_cards/mode_toggle"
  #resources :menu_cards
  resources :menu_cards do
    collection do
      get 'outlet_menu_association'
      put 'sale_price_update_by_category'
      put 'sale_price_update_by_brand_name'
      put 'sale_price_update_by_brand_name_and_category'
      post "add_rule_with_category_and_brand"
      post "thirdparty_outlet_upload"
    end
    member do
      get 'get_categories'
      get 'add_products'
      get 'copy'
      post 'clone'
      post "allocate_sale_rules_to_lots"
      post "allocate_sale_rules_to_menu_products"
    end
  end
  post "/menu_cards/:id/update_mode", to: 'menu_cards#update_mode', as: 'menu_card_update_mode'

  get "term_attributes/get_terms"
  resources :term_attributes

  resources :attributes

  resources :physical_types

  get "products/get_all_attributes"
  get "products/settings"
  get "products/product_edit"
  get "products/product_edit_unit"
  get "physical_types/show"
  post "products/product_update"
  get "products/product_edit_tax"
  post "products/product_tax_update"
  post "products/product_color_update"
  post "products/product_size_update"

  resources :categories do
    collection do
      post  '/bulk_upload',   to: "categories#bulk_upload", as: "bulk_upload"
    end
  end

  resources :suppliers

  get "units/get_tax_group"
  get "units/fetch_unit_details"
  get "units/fetch_drop"
  get "units/fetch_unit_type"
  get "units/fetch_sections"
  get "units/fetch_thirdparties"
  get "units/fetch_units"

  resources :units
  get "units/show_unit_type"

  resources :units do
    collection do
      post  '/thirdparty_upload',   to: "units#thirdparty_upload", as: "thirdparty_upload"
      post  '/urbanpiper_toggle',   to: "units#urbanpiper_toggle", as: "urbanpiper_toggle"
    end
  end

  resources :unittypes do
    member do
      get  '/fetch_units',   to: "unittypes#fetch_units"
    end
    collection do
      post 'sort'
    end
  end

  resources :products do
    collection do
      # post  '/bulk_upload',   to: "products#bulk_upload", as: "bulk_upload"
      get 'search_products'
      get  'new_import'
      get  'new_size_image_import'
      post  'import'
      post  'size_image_import'
      get  '/add_retail_items_to_catalog',   to: "products#add_retail_items_to_catalog", as: "add_retail_items_to_catalog"
      get  '/unit_products',   to: "products#unit_products", as: "unit_products"
      get  '/add_products',   to: "products#add_products", as: "add_products"
      post  '/save_products',   to: "products#save_products", as: "save_products"
      post 'delete_composition'
      post 'delete_product_image'
      post 'delete_product_size_image'
      post 'delete_vendor_product'
      post 'delete_menu_product'
      post 'delete_product_tag'
    end
    member do
      post  '/toggle_trash',   to: "products#toggle_trash", as: "toggle_trash"
      delete  '/remove_unit_product',   to: "products#remove_unit_product", as: "remove_unit_product"
      get '/process_dependency', to: "products#process_dependency", as: "process_dependency"
      post 'add_process_dependency'
      get 'edit_unit_products'
      post 'update_unit_products'
    end
  end

  #--------------------
  devise_for :users,:controllers => { :registrations =>'registration'}

  resources :roles 

  resources :users, :only => ['index', 'new', 'create', 'edit', 'update','destroy'] do
    collection do
      get 'new_import'
      post  '/import',   to: "users#import", as: "import"
      get  '/fetch_parent_users',   to: "users#fetch_parent_users"
      post 'update_custom_sync'
      get "get_users"
    end
  end
  #devise_for :users,:controllers => { :registrations =>'registration'}
  post "users/create_user"
  get "/users/:id/profile", to: 'users#profile', as: 'profile_user'
  get "/users/:id/toggle_status", to: 'users#toggle_status', as: 'toggle_status_user'
  get "/users/:id/delete", to: 'users#delete_user', as: 'delete_user'
  get "/users/:id/change_password", to: 'users#change_password', as: 'change_password_user'
  put "/users/:id/update_password", to: 'users#update_password', as: 'update_password_user'
  get "users/fetch_address_details"

  get 'dashboard' => 'home#dashboard'
  get "home/dashboard_chart"
  get "home/index"
  get "home/welcome"
  post "home/get_chart_data"
  get "home/get_map_data"
  get "home/get_inventory_data"

  get "/customers/:login/orders", to: 'customers#orders'
  get "/customers/:login/bills",  to: 'customers#bills'

  resources :tally_xml_exporter, only: [:index] do
    collection do
      get 'sales_xml', to: "tally_xml_exporter#sales_xml", as: "sales_xml"
      get 'purchase_xml', to: "tally_xml_exporter#purchase_xml", as: "purchase_xml"
      get 'from_date_to_date_xml', to: "tally_xml_exporter#from_date_to_date_xml", as: "from_date_to_date_xml"
      get 'voucher_xml', to: "tally_xml_exporter#voucher_xml", as: "voucher_xml"
      get 'hii_sales_xml', to: "tally_xml_exporter#hii_sales_xml", as: "hii_sales_xml"
      get 'hii_journal_xml', to: "tally_xml_exporter#hii_journal_xml", as: "hii_journal_xml"
    end
  end

  # get "home/unit_tree"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  #root :to => 'home#index'
  root :to => 'home#welcome'

  # get 'tally_xml_exporter/sales_xml', to: 'tally_xml_exporter#sales_xml'
  # get 'tally_xml_exporter/purchase_xml', to: 'tally_xml_exporter#purchase_xml'
  # get 'tally_xml_exporter/', to: 'tally_xml_exporter#index'



  resources :delivery_addresses, only: [:index, :show, :edit, :create, :update, :new, :destroy] do
    collection do
      get :fetch_address_details
      put :delete_address
    end
  end

  resources :paytm_securities, only: [:index, :create, :update, :new, :edit] do 
    collection do 
      get 'check_otp'
      get 'regenerate_otp' 
    end
  end
  resources :production_dashboard, only:[:index] do
    collection do 
      get 'get_production_date'
      get 'get_production_details_by_status'
    end
  end
  resources :sourcing_executives, only: [:index] do
    collection do 
      post 'create_allocation'
      get 'get_allocations'
      post 'remove_allocation'
      post 'update_allocation'
      post 'create_recursive_allocation'
      post "import"
      get "sample_csv"
      get 'vendor_inspections'
      post "remove_all_by_date" 
    end
  end 
  resources :bits do
  end
  resources :resource_managements, only:[:index]
  resources :expected_currencies do
    collection do 
      post "update_multiplier"
    end 
  end
# See how all your routes lay out with "rake routes"
# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id))(.:mount Browserlog::Engine => '/logs'
end