require 'json'
module MenuProductsHelper
  def get_tax_details(product_id)
    # @tax_details_json = ProductMetum.find(:all, :conditions => ['product_id =? AND meta_key =?', product_id, "tax"], :order => "id desc", :limit => 1).reverse # rails 4 comment
    @tax_details_json = ProductMetum.where("product_id =? AND meta_key =?", product_id, "tax").order("id desc").last
    if !@tax_details_json.empty?
      @tax_details_json.each do |kk|
        @tax_meta_json = kk.meta_value
      end
      @tax_meta = JSON.parse(@tax_meta_json)
    else
      @tax_meta['simple_tax_ammount'] = 0
      @tax_meta['cess_tax_ammount'] = 0
    end
    
    return @tax_meta
  end
  
  def get_menucard_details(menu_id)
    @menu_details = MenuCard.find(menu_id)    
    return @menu_details
  end
end

