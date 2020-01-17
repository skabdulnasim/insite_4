class ProductAttribute < ActiveRecord::Base
  attr_accessible :attribute_id, :product_id, :variations, :term_attribute

  belongs_to :product
  # belongs_to :  # rails 4 migration comment
  belongs_to :p_attribute, class_name: "Attribute", foreign_key: "attribute_id"
  belongs_to :term_attribute


  def self.save_product_attributes(product,param_attributes,variants)
    param_attributes.each do |attr|
      product_attributes = ProductAttribute.new
      product_attributes[:product_id]=product.id
      product_attributes[:attribute_id]= attr

      product_variant_array = Array.new
      if variants
        variants.each do |t_a|
          _term_attr = TermAttribute.find(t_a)
          if "#{_term_attr.p_attribute.id}" == attr
            product_variant_array_assoc = {}
            product_variant_array_assoc["#{_term_attr.id}"] = "#{_term_attr.name}"
            product_variant_array.push product_variant_array_assoc
            product_attributes[:term_attribute_id]= _term_attr.id
          end
        end
        product_variant = variants
        product_variant_json = JSON.generate(product_variant_array)
        product_attributes[:variations] = product_variant_json
      end
      product_attributes.save
    end
  end
end
