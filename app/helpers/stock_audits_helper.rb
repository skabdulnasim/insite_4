module StockAuditsHelper
	def build_condition_hash(color_id,size_id,model_no,batch_no,sell_price)
		condition_hash = {:color_id=>color_id,:size_id=>size_id,:model_number=>model_no,:batch_no=>batch_no,:sell_price_with_tax=>sell_price}
		condition_hash[:color_id]= [nil,''] if condition_hash[:color_id] == nil
    condition_hash[:size_id]= [nil,''] if condition_hash[:size_id] == nil
    condition_hash[:model_number]= [nil,''] if condition_hash[:model_number] == nil
    condition_hash[:batch_no]= [nil,''] if condition_hash[:batch_no] == nil	
		return condition_hash
	end
end
