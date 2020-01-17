json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_denomination_not_showing) : I18n.t(:success_denomination_showing, count: @countries.count)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_denomination_showing, count: @countries.count)
  
end 
if @error.present?
  json.data Array.new
else
  json.data @countries do |country|
  	json.extract! country, :id, :name, :code, :currency
	  json.denominations country.denominations do |denomination|
	    json.extract! denomination, :id, :name, :value, :image
	  end
  end	
end