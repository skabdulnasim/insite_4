class ThirdpartyItemAction < ActiveRecord::Base
  attr_accessible :menu_product_id, :action, :master_section_id

  scope :menu_product_id_in, lambda {|menu_product_ids| where(["menu_product_id in (?)", menu_product_ids])}
  scope :menu_product_and_action, lambda {|menu_product_id,action| where(["menu_product_id =? AND action=?", menu_product_id,action])}

  def self.import_product_thirdparty_stock(master_section_id,menu_products,status)
    imported_product_thirdparty_stock =Array.new
    data_errors = Array.new
    menu_products.each do |mp|
      urbanpipar_stock_status = ThirdpartyItemAction.find_by_menu_product_id_and_master_section_id(mp,master_section_id).present? ? ThirdpartyItemAction.find_by_menu_product_id_and_master_section_id(mp,master_section_id).update_attributes(:action => status) : ThirdpartyItemAction.create(:menu_product_id => mp, :master_section_id => master_section_id, :action => status)
    end
  end

end
