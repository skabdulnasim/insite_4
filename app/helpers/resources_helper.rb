module ResourcesHelper
	def get_resource_color(state)
    if state == 1
      "green"
    elsif state ==2
      "orange"
    elsif state ==3
      "purple"
    elsif state ==4
      "red"
    elsif state ==5
      "blue"
    elsif state ==6
      "grey"
    end
  end

  def get_actived_qty(product_id,resource_id,month,year)
    UserSale.by_resource_id(resource_id).by_recorded_at_month_range(month,month).by_recorded_at_year_range(year,year).sum(:quantity)
  end
end
