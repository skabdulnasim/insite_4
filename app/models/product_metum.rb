class ProductMetum < ActiveRecord::Base
  attr_accessible :meta_value, :meta_key
  
  belongs_to :product

  # => model scopes
  scope :type_raw,    lambda { where(["meta_key = ?",'raw']) }
  scope :set_type,    lambda {|type|where(["meta_key = ?", type])}
  scope :set_product, lambda {|product_id|where(["product_id = ?", product_id])}


  def self.save_product_metum_attributes(product,_product_metum_attributes,term_attribute)
    _product_attr_json = JSON.generate(term_attribute)
    _product_metum_attributes[:meta_value] = _product_attr_json
    _product_metum_attributes[:meta_key] = "attributes"
    _product_metum_attributes[:product_id] = product.id
    _product_metum_attributes.save
  end

  def self.save_product_metum_variants(product,_product_metum_variants,variant)
    _product_variant_json = JSON.generate(variant)
    _product_metum_variants[:meta_value] = _product_variant_json
    _product_metum_variants[:meta_key] = "variants"
    _product_metum_variants[:product_id] = product.id
    _product_metum_variants.save
  end

  def self.save_product_metum_raw(product,_product_metum_raw,checked_raw)
    _checked_details_json = JSON.generate(checked_raw)
    _product_metum_raw[:meta_value] = _checked_details_json
    _product_metum_raw[:meta_key] = "raw"
    _product_metum_raw[:product_id] = product.id
    _product_metum_raw.save
  end

  def self.save_product_metum_info(product,_product_metum_info,info_json)
    _product_metum_info[:meta_value] = JSON.generate(info_json)
    _product_metum_info[:meta_key] = "info"
    _product_metum_info[:product_id] = product.id
    _product_metum_info.save
  end

end
