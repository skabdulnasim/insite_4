class ComboItem < ActiveRecord::Base
  attr_accessible :color_id, :item_id, :menu_product_id, :mode, :sell_price, :sell_price_without_tax, :size_id, :tax_group_id, :quantity
  #Model association
  belongs_to :menu_product
  belongs_to :tax_group
  belongs_to :product, :class_name => "Product", :foreign_key => :item_id
  #MOdel Callback
  after_create :assign_tax_group

  def assign_tax_group
    update_attribute(:tax_group_id, set_tax_group) unless self.tax_group_id.present?
    update_attribute(:sell_price_without_tax, compute_sell_price_without_tax)
  end

  def compute_sell_price_without_tax
    if AppConfiguration.get_config_value('variable_tax') == 'enabled'
      _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
      _total_amnt = 0
      i = 1
      @tax_array = self.tax_group.tax_classes
      @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
      @tax_array.each do |tc|
        if tc.tax_type == 'variable'
          if self.sell_price.to_f <= _limit_vtax
            if i == 1
              _total_amnt = _total_amnt + 2.5    
            elsif i == 2
              _total_amnt = _total_amnt + 2.5
            end
          else
            if i == 3
              _total_amnt = _total_amnt + 6
            elsif i == 4
              _total_amnt = _total_amnt + 6
            end
          end 
        else
          _total_amnt = _total_amnt + tc[:ammount].to_f  
        end
        i += 1
      end
      (self.sell_price.to_f * 100)/(_total_amnt.to_f + 100)
    else  
      (self.sell_price.to_f * 100)/(self.tax_group.total_amnt.to_f + 100)
    end
  end

  def set_tax_group
    _menu_product = self.menu_product.menu_card.menu_products.find_by_product_id(self.item_id)
    tax_group = _menu_product.present? ? _menu_product.tax_group_id : nil
  end

end
