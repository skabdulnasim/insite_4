class ProductAttributeSet < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :is_default, :name
  
  has_many :product_attribute_groups
  has_many :product_attribute_keys, :through => :product_attribute_groups

  def keys
    ProductAttributeKey.includes(:product_attribute_groups => :product_attribute_set).where(["id = ?", self])
  end

  def self.seed_data
    _default_set = ProductAttributeSet.create(:name => "Default", :is_default => true)
    _gereral_group = _default_set.product_attribute_groups.create(:name => "General", :is_system_entity => true)
    # Adding attributes for General group
    _attr_sku = ProductAttributeKey.create(:attribute_code => 'sku', :input_type => 'text_field', :label=>"SKU", :is_unique => true, :is_required => true, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _gereral_group.product_attribute_keys << _attr_sku
    _attr_sn = ProductAttributeKey.create(:attribute_code => 'short_name', :input_type => 'text_field', :label=>"Short Name", :is_unique => true, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _gereral_group.product_attribute_keys << _attr_sn
    _attr_bt = ProductAttributeKey.create(:attribute_code => 'business_type',:input_type => 'select', :label=>"Sell Product", :is_unique => false,  :is_required => true,   :is_comparable => false, :is_system_entity => true, :is_sortable => false)
      _attr_bt.product_attribute_options.create([
          {:value => "by_catalog", :label=>"By Catalog", :is_default=>true}, 
          {:value => "by_item_sku", :label=>"By item SKU"},
          {:value => "by_mrp", :label=>"By Stock MRP"},
          {:value => "by_weight", :label=>"By Stock Weight"},
          {:value => "by_bulk_weight", :label=>"By Bulk Weight"}
      ])
    _gereral_group.product_attribute_keys << _attr_bt
    _attr_status = ProductAttributeKey.create(:attribute_code => 'status', :input_type => 'select', :label=>"Status", :is_unique => false,  :is_required => true,   :is_comparable => false, :is_system_entity => true, :is_sortable => false)
      _attr_status.product_attribute_options.create([
        {:value => "enabled", :label=>"Enabled", :is_default=>true}, 
        {:value => "disabled", :label=>"Disabled"}
      ])
    _gereral_group.product_attribute_keys << _attr_status
    _attr_tax = ProductAttributeKey.create(:attribute_code => 'tax_group', :input_type => 'select', :label=>"Tax Group", :is_unique => false,  :is_required => false,  :is_comparable => false, :is_system_entity => true, :is_sortable => false)    
    _gereral_group.product_attribute_keys << _attr_tax
    _attr_weight = ProductAttributeKey.create(:attribute_code => 'weight', :input_type => 'text_field', :label=>"Weight", :is_unique => false,  :is_required => false,  :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _gereral_group.product_attribute_keys << _attr_weight
    _attr_physical_type = ProductAttributeKey.create(:attribute_code => 'physical_type_id', :input_type => 'select', :label=>"Physical Type", :is_unique => false,  :is_required => false,  :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _gereral_group.product_attribute_keys << _attr_physical_type    
    _attr_new_from = ProductAttributeKey.create(:attribute_code => 'new_from_date', :input_type => 'date_field', :label=>"Set Product as New from Date", :is_unique => false,  :is_required => false,  :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _gereral_group.product_attribute_keys << _attr_new_from
    _attr_new_till = ProductAttributeKey.create(:attribute_code => 'new_till_date', :input_type => 'date_field', :label=>"Set Product as New to Date", :is_unique => false,  :is_required => false,  :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _gereral_group.product_attribute_keys << _attr_new_till
    
    # Adding attributes for Prices group
    _price_group = _default_set.product_attribute_groups.create(:name => "Prices", :is_system_entity => true)
    _attr_price = ProductAttributeKey.create(:attribute_code => 'price', :input_type => 'text_field', :label=>"Price", :is_unique => false, :is_required => false, :is_comparable => true, :is_system_entity => true, :is_sortable => true)
    _price_group.product_attribute_keys << _attr_price
    _attr_s_price = ProductAttributeKey.create(:attribute_code => 'special_price', :input_type => 'text_field', :label=>"Special Price", :is_unique => false, :is_required => false, :is_comparable => true, :is_system_entity => true, :is_sortable => true)
    _price_group.product_attribute_keys << _attr_s_price
    _attr_sp_from = ProductAttributeKey.create(:attribute_code => 'special_price_from_date', :input_type => 'date_field', :label=>"Special Price From Date", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _price_group.product_attribute_keys << _attr_sp_from
    _attr_sp_till = ProductAttributeKey.create(:attribute_code => 'special_price_till_date', :input_type => 'date_field', :label=>"Special Price To Date", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _price_group.product_attribute_keys << _attr_sp_till

    # Adding attributes for Inventory group
    _inventory_group = _default_set.product_attribute_groups.create(:name => "Inventory", :is_system_entity => true)
    _attr_stack = ProductAttributeKey.create(:attribute_code => 'stack_level', :input_type => 'text_field', :label=>"Stack Level", :is_unique => false, :is_required => false, :is_comparable => true, :is_system_entity => true, :is_sortable => true, :default_value => "1")
    _inventory_group.product_attribute_keys << _attr_stack
    _attr_inventory = ProductAttributeKey.create(:attribute_code => 'manage_inventory', :input_type => 'select', :label=>"Manage Inventory for this Product?", :is_unique => false, :is_required => false, :is_comparable => true, :is_system_entity => true, :is_sortable => true)
      _attr_inventory.product_attribute_options.create([
        {:value => "yes", :label=>"Yes", :is_default=>true}, 
        {:value => "no", :label=>"No"}
      ])
    _inventory_group.product_attribute_keys << _attr_inventory

    # Adding attributes for Meta Data group
    _meta_group = _default_set.product_attribute_groups.create(:name => "Meta Information", :is_system_entity => true)
    _attr_meta_t = ProductAttributeKey.create(:attribute_code => 'meta_title', :input_type => 'text_field', :label=>"Meta Title", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _meta_group.product_attribute_keys << _attr_meta_t
    _attr_meta_k = ProductAttributeKey.create(:attribute_code => 'meta_keywords', :input_type => 'text_area', :label=>"Meta Keywords", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _meta_group.product_attribute_keys << _attr_meta_k
    _attr_meta_d = ProductAttributeKey.create(:attribute_code => 'meta_description', :input_type => 'text_area', :label=>"Meta Description", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _meta_group.product_attribute_keys << _attr_meta_d

    # Adding attributes for Images group
    _image_group = _default_set.product_attribute_groups.create(:name => "Images", :is_system_entity => true)
    _attr_thumb = ProductAttributeKey.create(:attribute_code => 'thumbnail', :input_type => 'file_field', :label=>"Thumbnail", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _image_group.product_attribute_keys << _attr_thumb
    _attr_smimage = ProductAttributeKey.create(:attribute_code => 'small_image', :input_type => 'file_field', :label=>"Small Image", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _image_group.product_attribute_keys << _attr_smimage
    _attr_base_img = ProductAttributeKey.create(:attribute_code => 'base_image', :input_type => 'file_field', :label=>"Base Image", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _image_group.product_attribute_keys << _attr_base_img
    _attr_glry_img = ProductAttributeKey.create(:attribute_code => 'gallery_image', :input_type => 'file_field', :label=>"Gallery Image", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _image_group.product_attribute_keys << _attr_glry_img

    _description_group = _default_set.product_attribute_groups.create(:name => "Descriptions", :is_system_entity => true)
    _attr_short_d = ProductAttributeKey.create(:attribute_code => 'short_description', :input_type => 'text_area', :label=>"Short Description", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _description_group.product_attribute_keys << _attr_short_d
    _attr_long_desc = ProductAttributeKey.create(:attribute_code => 'long_description', :input_type => 'file_field', :label=>"Long Description", :is_unique => false, :is_required => false, :is_comparable => false, :is_system_entity => true, :is_sortable => false)
    _description_group.product_attribute_keys << _attr_long_desc    
  end
end
