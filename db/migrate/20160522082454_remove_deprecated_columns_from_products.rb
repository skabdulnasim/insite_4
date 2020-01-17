class RemoveDeprecatedColumnsFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :sku
    remove_column :products, :product_image
    remove_column :products, :valid_from
    remove_column :products, :short_name
    remove_column :products, :physical_type_id
    remove_column :products, :unittype_id
    remove_column :products, :image_file_name
    remove_column :products, :image_content_type
    remove_column :products, :image_file_size
    remove_column :products, :image_updated_at
    remove_column :products, :stack_level
    remove_column :products, :basic_unit
    remove_column :products, :is_trashed
    if column_exists? :products, :price
      remove_column :products, :price
    end
    if column_exists? :products, :sell_type
      remove_column :products, :sell_type
    end    
    if column_exists? :products, :tax_class_id
      remove_column :products, :tax_class_id
    end    
    if column_exists? :products, :tax_ammount
      remove_column :products, :tax_ammount
    end    
    if column_exists? :products, :product_attributes
      remove_column :products, :product_attributes
    end    
    if column_exists? :products, :is_deleted
      remove_column :products, :is_deleted
    end                    
  end

  def down
  end
end
