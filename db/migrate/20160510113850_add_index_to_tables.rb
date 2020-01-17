class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :accounts, :user_id

    add_index :account_payments, :user_id

    add_index :advertisement_galleries, :advertisement_id

    add_index :audits, :product_id
    add_index :audits, :store_id
    
    add_index :bill_discounts, :bill_id
    
    add_index :bill_orders, :bill_id
    add_index :bill_orders, :order_id
    
    add_index :bill_split_products, :bill_split_id
    add_index :bill_split_products, :product_id
    
    add_index :bill_splits, :bill_id
    add_index :bill_splits, :unit_id
    add_index :bill_splits, :user_id
    
    add_index :bill_tax_amounts, :bill_id
    add_index :bill_tax_amounts, :tax_class_id
    
    add_index :bills, :unit_id
    add_index :bills, :deliverable_id
    add_index :bills, :device_id
    add_index :bills, :biller_id
    
    add_index :chairs, :table_id
    
    add_index :delivery_boys_units, :account_id

    # add_index :invoices, :order_id
    # add_index :invoices, :from_store_id
    # add_index :invoices, :to_store_id
    # add_index :invoices, :product_id
    
    add_index :kitchen_production_audits, :product_id
    add_index :kitchen_production_audits, :store_id
    add_index :kitchen_production_audits, :stock_transfer_id
    add_index :kitchen_production_audits, :audit_id
    
    # add_index :kitchen_productions, :kitchen_transfers_transaction_id
    # add_index :kitchen_productions, :product_id
    # add_index :kitchen_productions, :store_id
    # add_index :kitchen_productions, :to_store_id

    add_index :kitchen_transfers, :kitchen_store_id
    add_index :kitchen_transfers, :product_id
    add_index :kitchen_transfers, :transaction_id

    add_index :loyalty_cards, :customer_id

    add_index :menu_cards, :unit_id
    add_index :menu_cards, :section_id
    add_index :menu_cards, :master_menu_id

    add_index :menu_card_menu_categories, :menu_card_id
    add_index :menu_card_menu_categories, :menu_category_id

    add_index :menu_product_combinations, :menu_product_id
    add_index :menu_product_combinations, :combination_type_id
    add_index :menu_product_combinations, :product_id
    add_index :menu_product_combinations, :combinations_rule_id
    add_index :menu_product_combinations, :product_unit_id

    add_index :menu_categories, :unit_id
    add_index :menu_categories, :menu_card_id

    add_index :menu_products, :product_id
    add_index :menu_products, :menu_category_id
    add_index :menu_products, :menu_card_id
    add_index :menu_products, :variable_id
    add_index :menu_products, :tax_group_id
    add_index :menu_products, :store_id
    add_index :menu_products, :sort_id
    add_index :menu_products, :combo_id
    
    add_index :order_detail_combinations, :order_detail_id
    add_index :order_detail_combinations, :menu_product_combination_id
    add_index :order_detail_combinations, :product_id
    add_index :order_detail_combinations, :unit_id
    
    add_index :order_details, :order_id
    add_index :order_details, :menu_product_id
    add_index :order_details, :sort_id
    add_index :order_details, :product_id
    add_index :order_details, :unit_id

    add_index :order_status_logs, :unit_id
    add_index :order_status_logs, :order_id
    add_index :order_status_logs, :order_status_id
    add_index :order_status_logs, :user_id
    
    add_index :orders, :order_status_id
    add_index :orders, :user_id
    add_index :orders, :unit_id
    add_index :orders, :deliverable_id
    add_index :orders, :consumer_id
    add_index :orders, :delivery_boy_id
    add_index :orders, :device_id
    
    add_index :payments, :settlement_id
    add_index :payments, :paymentmode_id
    
    add_index :pos_terminals, :unit_id
    
    add_index :printers, :unit_id
    add_index :printers, :assignable_id
    
    add_index :product_attributes, :product_id
    add_index :product_attributes, :attribute_id
    add_index :product_attributes, :term_attribute_id
    
    # add_index :product_compositions, :product_id
    # add_index :product_compositions, :raw_product_id
    
    add_index :product_meta, :product_id
    
    add_index :product_transaction_units, :product_id
    add_index :product_transaction_units, :product_unit_id
    add_index :product_transaction_units, :basic_unit_id
    
    add_index :product_units, :product_basic_unit_id
    
    add_index :products, :category_id
    add_index :products, :physical_type_id
    add_index :products, :unittype_id
    add_index :products, :basic_unit_id
    
    add_index :purchase_order_meta, :purchase_order_id
    add_index :purchase_order_meta, :product_id
    add_index :purchase_order_meta, :secondary_product_unit_id
    
    add_index :purchase_order_stocks, :product_id
    add_index :purchase_order_stocks, :vendor_id
    
    add_index :purchase_orders, :store_id
    add_index :purchase_orders, :unit_id
    add_index :purchase_orders, :user_id
    add_index :purchase_orders, :vendor_id
    
    add_index :report_preferences, :unit_id
    
    add_index :room_payments, :room_id
    
    add_index :rooms, :unit_id
    
    add_index :rscratch_exception_logs, :exception_id
    
    add_index :secondary_stocks, :stock_id
    add_index :secondary_stocks, :store_id
    add_index :secondary_stocks, :product_id
    add_index :secondary_stocks, :product_unit_id
    
    add_index :settlements, :bill_id
    add_index :settlements, :client_id
    add_index :settlements, :split_bill_id
    add_index :settlements, :device_id
    
    add_index :sorts, :unit_id
    
    add_index :stock_audit_meta, :stock_audit_id
    add_index :stock_audit_meta, :product_id
    
    add_index :stock_audits, :store_id
    
    add_index :stock_prices, :stock_id
    add_index :stock_prices, :product_id
    
    add_index :stock_production_meta, :stock_production_id
    add_index :stock_production_meta, :product_id
    add_index :stock_production_meta, :store_id
    
    add_index :stock_production_raws, :stock_production_meta_id
    add_index :stock_production_raws, :target_product_id
    add_index :stock_production_raws, :product_id
    add_index :stock_production_raws, :store_id
    
    add_index :stock_productions, :kitchen_store_id
    add_index :stock_productions, :store_id
    
    add_index :stock_purchases, :purchase_order_id
    add_index :stock_purchases, :store_id
    
    add_index :stock_taxes, :stock_id
    add_index :stock_taxes, :tax_class_id
    
    add_index :stock_transfer_invoice_meta, :stock_transfer_invoice_id
    add_index :stock_transfer_invoice_meta, :product_id
    
    add_index :stock_transfer_invoices, :stock_transfer_id
    
    add_index :stock_transfer_template_products, :stock_transfer_template_id, :name => "stock_transfer_template_ref"
    
    add_index :stocks, :product_id
    add_index :stocks, :store_id
    # add_index :stocks, :stock_transaction_id
    
    add_index :stock_transfers, :primary_store_id
    add_index :stock_transfers, :secondary_store_id
    add_index :stock_transfers, :vehicle_id
    add_index :stock_transfers, :invoice_id
    add_index :stock_transfers, :activity_id
    add_index :stock_transfers, :store_requisition_log_id
    
    add_index :stock_updates, :store_id
    add_index :stock_updates, :product_id
    add_index :stock_updates, :stock_ref_id
    
    add_index :store_products, :store_id
    add_index :store_products, :product_id
    
    add_index :store_requisition_logs, :store_id
    add_index :store_requisition_logs, :from_store_id
    add_index :store_requisition_logs, :store_requisition_id
    
    add_index :store_requisition_meta, :requisition_id
    add_index :store_requisition_meta, :product_id
    add_index :store_requisition_meta, :product_unit_id
    
    add_index :table_reservations, :section_id
    add_index :table_reservations, :unit_id
    add_index :store_requisitions, :store_id
    add_index :store_requisitions, :unit_id
    add_index :store_requisitions, :user_id
    
    add_index :stores, :unit_id
    
    add_index :table_reservation_meta, :table_reservation_id
    add_index :table_reservation_meta, :table_id
    
    add_index :table_status_logs, :outlet_id
    add_index :table_status_logs, :table_id
    add_index :table_status_logs, :table_state_id
    add_index :table_status_logs, :user_id
    add_index :table_status_logs, :device_id
    
    add_index :table_swap_logs, :order_id
    add_index :table_swap_logs, :old_table_id
    add_index :table_swap_logs, :new_table_id
    add_index :table_swap_logs, :user_id
    add_index :table_swap_logs, :device_id
    
    add_index :tables, :unit_id
    add_index :tables, :table_state_id
    add_index :tables, :last_bill_id
    add_index :tables, :section_id
    add_index :tables, :user_id
    
    add_index :tax_classes_tax_groups, :tax_group_id
    
    add_index :tax_groups, :section_id
    
    add_index :term_attributes, :attribute_id
    
    add_index :third_party_payments, :third_party_payment_option_id
    
    add_index :unit_advertisements, :unit_id
    add_index :unit_advertisements, :advertisement_id
    
    add_index :units, :unittype_id
    
    add_index :unit_details, :unit_id
    
    add_index :unit_products, :product_id
    add_index :unit_products, :unit_id

    if column_exists? :unit_products, :tax_group_id
      add_index :unit_products, :tax_group_id
    end
    
    add_index :users, :unit_id
    
    add_index :users_roles, :user_id
    add_index :users_roles, :role_id
    
    add_index :vehicles, :unit_id
    
    add_index :vendor_products, :vendor_id
    add_index :vendor_products, :product_id
    
    add_index :vendors, :unit_id
  end
end
