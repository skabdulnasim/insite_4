class LotsController < ApplicationController
	def show
		@lot = Lot.find(params[:id])
		@lot["lot_sale_rules"] = @lot.sale_rules
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lot }
    end
	end
	def delete_lot_sale_rule
    @lot_sale_rule = LotSaleRule.find_by_lot_id_and_sale_rule_id(params[:lot_id],params[:sale_rule_id])
    @lot_sale_rule.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  def lot_quick_update
    @lot = Lot.find(params[:lot_id])
    _limit_vtax = AppConfiguration.get_config('vtax_five_percent_limit').present? ? AppConfiguration.get_config('vtax_five_percent_limit').to_f : 1120
    @lot.update_attributes(:sell_price => params[:sell_price], :expiry_date => params[:expiry_date], :mrp => params[:mrp])
    _total_tax_amnt = 0
    i = 1
    @tax_array = @lot.tax_group.tax_classes
    @tax_array.sort { |a, b|  a.ammount <=> b.ammount }
    @tax_array.each do |tc|
      if tc.tax_type == 'variable'
        # if ((tc.lower_limit + (tc.lower_limit * tc.ammount)/100)..(tc.upper_limit + (tc.upper_limit * tc.ammount)/100)).include?(@lot.sell_price.to_f)
        #   if params[:sell_price].to_f <= _limit_vtax
        #     _total_tax_amnt = _total_tax_amnt + 2.5
        #   else
        #     _total_tax_amnt = _total_tax_amnt + 6  
        #   end  
        # end 
        if @lot.sell_price.to_f <= _limit_vtax
          if i == 1
            _total_tax_amnt = _total_tax_amnt + 2.5    
          elsif i == 2
            _total_tax_amnt = _total_tax_amnt + 2.5
          end
        else
          if i == 3
            _total_tax_amnt = _total_tax_amnt + 6
          elsif i == 4
            _total_tax_amnt = _total_tax_amnt + 6
          end
        end 
      else
        _total_tax_amnt = _total_tax_amnt + tc[:ammount].to_f  
      end
      i += 1
    end
    sale_price_without_tax = 0
    sale_price_without_tax = (@lot.sell_price.to_f * 100)/(_total_tax_amnt.to_f + 100)
    @lot.update_attributes(:sell_price_without_tax => sale_price_without_tax)

    respond_to do |format|
      format.json { render json: @lot }
    end
  end
end