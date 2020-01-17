module ProductManagement
  def self.get_product_details_by_id(id)
    _product_details=Product.find(id)
    return _product_details
  end
  
  def self.get_product_meta(product_id, meta_key)
    # @product_meta_json = ProductMetum.find(:all, :conditions => ['product_id =? AND meta_key =?', product_id, meta_key], :order => "id desc", :limit => 1).reverse # rails 4 comment
    @product_meta_json = ProductMetum.where('product_id =? AND meta_key =?', product_id, meta_key).order("id desc")
    if @product_meta_json[0]
      @product_meta = JSON.parse(@product_meta_json[0].meta_value)
      return @product_meta
    end
  end
  
  #Get products of a category
  def self.get_products_by_cat_id(id)
    _products = Product.where(:category_id => id)
    return _products
  end
  
  
  def self.get_sub_products(id)
    _product_raw = ProductMetum.where("product_id =? AND meta_key =?", id, "raw")
    if _product_raw.present?
      _product_raw_meta = JSON.parse(_product_raw[0][:meta_value])
    else
      _product_raw_meta = ""
    end
    return _product_raw_meta
  end  
  
  def self.get_product_unit_details(id)
    _product_unit_details = ProductUnit.find(id)
    return _product_unit_details
  end 
  
  def self.get_product_tax_details(id)
    _product_unit_details = ProductUnit.find(id)
    return _product_unit_details
  end  
end