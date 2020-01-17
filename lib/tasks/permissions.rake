namespace 'permissions' do
  desc "Loading all models and their related controller methods in permissions table."
  task(:index => :environment) do
    arr = []
    #load all the controllers
    controllers = Dir.new("#{Rails.root}/app/controllers").entries
    controllers.each do |entry|
      if entry =~ /_controller/
        #check if the controller is valid
        arr << entry.camelize.gsub('.rb', '').constantize
      elsif entry =~ /^[a-z]*$/ #nameall controllers
        Dir.new("#{Rails.root}/app/controllers/#{entry}").entries.each do |x|
          if x =~ /_controller/
            arr << "#{entry.titleize}::#{x.camelize.gsub('.rb', '')}".constantize
          end
        end
      end
    end
    # Application modules
    app_modules = {}
    app_modules['branch_modules'] = ['Unit', 'Unittype', 'Section', 'Sort', 'Table', 'PosTerminal', 'Printer']
    app_modules['catalog_modules'] = ['Product', 'ProductAttributeSet', 'ProductAttributeGroup', 'ProductUnit', 'Category', 'MenuCard', 'MenuCategory', 'MenuProduct', 'CombinationType', 'CombinationsRule']
    app_modules['inventory_modules'] = ['Store', 'Vehicle', 'Vendor', 'Stock', 'StoreRequisition', 'StoreRequisitionMetum', 'PurchaseOrder', 'PurchaseOrderMetum', 'StockPurchase', 'StockTransfer', 'StockTransferTemplate', 'StockAudit', 'StockProduction', 'KitchenProductionAudit']
    app_modules['tax_modules'] = ['TaxGroup', 'TaxClass']
    app_modules['order_modules'] = ['Order', 'OrderDetail', 'Bill', 'Settlement', 'ReturnItem']
    app_modules['promotion_modules'] = ['LoyaltyCard', 'LoyaltyCardClass', 'LoyaltyPurchase', 'LoyaltyCardPayment', 'LoyaltyCardTransaction', 'AlphaPromotion']
    app_modules['report_modules'] = ['CustomReport', 'ReportFolder', 'Report']
    app_modules['user_modules'] = ['User', 'Role', 'Customer', 'DeliveryBoy']
    app_modules['configuration_modules'] = ['AppConfiguration', 'FormOfPayment', 'OrderStatus', 'TableState', 'TableType', 'ThirdPartyPaymentOption']
    app_modules['other_modules'] = ['TermAttribute', 'PhysicalType', 'Medium']
    
    app_modules.keys.map { |e| PermissionGroup.create(:name => e) }
    _permission_groups = PermissionGroup.all
    _group_id = _permission_groups.last.id
    # permission for all actions
    write_permission("all", "manage", "Manage all",_group_id)    
    arr.each do |controller|
      #only that controller which represents a model
      if controller.permission
        # set_group(controller.permission)
        _permission_groups.each do |group|
          if app_modules["#{group.name}"].include? controller.permission
            _group_id = group.id
          end
        end        
        #create a universal permission for that model. eg "manage User" will allow all actions on User model.
        write_permission(controller.permission, "manage", 'manage', _group_id) #add permission to do CRUD for every model.
        write_permission(controller.permission, "read", 'read', _group_id) #add permission to do CRUD for every model.
        # Actions which will not be saved
        unpermitted_actions = ['apipie_validations', 'get_current_user', 'get_current_user_id', 'smart_listing', 'smart_listing_create']
        controller.action_methods.each do |method|
          if method =~ /^([A-Za-z\d*]+)+([\w]*)+([A-Za-z\d*]+)$/ #add_user, add_user_info, Add_user, add_User
            unless unpermitted_actions.include? method
              name, cancan_action = eval_cancan_action(method)
              write_permission(controller.permission, cancan_action, name, _group_id)
            end
          end
        end
      end
    end

  end
end
 
#this method returns the cancan action for the action passed.
def eval_cancan_action(action)
  case action.to_s
  when "index"
    name = 'list'
    cancan_action = "index"#let the cancan action be the actual method name</strong>
    action_desc = "List"
  when "new", "create"
    name = 'create and update'
    cancan_action = "create"
    action_desc = "Create"
  when "show"
    name = 'view'
    cancan_action = "view"
    action_desc = "View"
  when "edit", "update"
    name = 'create and update'
    cancan_action = "update"
    action_desc = "Update"
  when "delete", "destroy"
    name = 'delete'
    cancan_action = "destroy"
    action_desc = "Destroy"
  else
    name = action.to_s
    cancan_action = action.to_s
    action_desc = "Other: " < cancan_action
  end
  return name, cancan_action
end
 
#check if the permission is present else add a new one.
def write_permission(model, cancan_action, name, group_id)
  permission = Permission.where("subject_class = ? and action = ?", model, cancan_action).first
  unless permission
    permission = Permission.new(:description => name, :subject_class => model, :action => cancan_action, :permission_group_id => group_id)
    permission.save
  end
end