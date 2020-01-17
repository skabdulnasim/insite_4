class MigrateProductAttributeData < ActiveRecord::Migration
  def up
    # Set product_attribute_set_id for all rows
    _products = Product.all
    _products.map { |p| p.update_attribute(:product_attribute_set_id, 1) }
    _products.each do |product|
      puts "Migrating data of #{product.name}"
      # Migrate business type data
      _business_type = product.sell_type.present? ? product.sell_type : 'by_catalog'
      _business_type = (_business_type == 'by_tray_weight') ? 'by_bulk_weight' : _business_type
      puts "Sell type: #{product.sell_type}, Business type: #{_business_type}"
      product.update_attribute(:business_type, _business_type) unless product.business_type.present?
      # Migrate other attributes
      product.product_attribute_set.product_attribute_groups.each do |g|
        g.product_attribute_keys.each do |k|
          _value = product.sku if k.attribute_code == 'sku'
          _value = product.short_name if (k.attribute_code == 'short_name' and product.short_name.present?)
          _value = product.physical_type_id if k.attribute_code == 'physical_type_id'
          _value = product.stack_level if (k.attribute_code == 'stack_level' and product.stack_level.present?)
          _value = product.price if (k.attribute_code == 'price' and product.price.present?)
          _value = "enabled" if k.attribute_code == 'status'
          _value = "yes" if k.attribute_code == 'manage_inventory'
          _value ||= ""
          _attr = product.properties.create(:product_attribute_key_id =>k.id, :value => _value)
        end
      end
    end
  end

  def down
    ProductAttributeValue.delete_all
  end
end