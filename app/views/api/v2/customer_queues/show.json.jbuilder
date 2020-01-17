json.status @error.present? ? I18n.t(:error) : I18n.t(:ok)
json.messages do
  json.simple_message @error.present? ? I18n.t(:error_try_after_sometime) : I18n.t(:success_record_found)
  json.internal_message @error.present? ? @error.message : I18n.t(:success_record_found)
  json.error_code @log[:log_serial] if @error.present? and @log.present?
  json.error_url @log[:log_url] if @error.present? and @log.present?
end 
if @error.present?
  json.data Hash.new
else
  json.data do
		json.count @customer_queues.count
		json.customer_queues @customer_queues do |customer_que|
			json.extract! customer_que, :id, :pax, :trash, :is_reserved, :total_pax, :unit_id, :is_preauth, :customer_id, :customer_queue_state_id, :slot_id, :reference_id
			json.from_date customer_que.from_date.strftime("%d-%m-%Y, %I:%M %p")
			json.to_date customer_que.to_date.strftime("%d-%m-%Y, %I:%M %p")
			if customer_que.customer_queue_state_id.present?
				json.customer_queue_states do 
					json.extract! customer_que.customer_queue_state, :id, :name, :color_code if customer_que.customer_queue_state.present?
				end
			end	
			if @resources.include? 'unit'
				json.unit do
					json.extract! customer_que.unit, :id, :unit_name, :address, :landmark, :locality, :pincode, :city, :state, :country, :time_zone, :latitude, :longitude, :phone
  				json.section do 
				    json.extract! Section.unit_sections(customer_que.unit.id).dinein_section.first, :id , :name, :section_type
				    json.dinein_menu_card do
				      json.extract! Section.unit_sections(customer_que.unit.id).dinein_section.first.menu_cards.active.first, :id, :name, :master_menu_id, :scope, :updated_at
				    end
				  end
				end
			end	
			if @resources.include? 'customer'
				json.customer do
				  json.extract! customer_que.customer, :id, :email, :mobile_no, :customer_unique_id
				  json.name "#{customer_que.customer.customer_profile.firstname}" " #{customer_que.customer.customer_profile.lastname}"  
				  json.custmer_profile do
				  	json.extract! customer_que.customer.customer_profile, :id, :firstname, :lastname, :address, :age, :anniversary, :contact_no, :dob, :gender
				  end
				  if customer_que.customer.addresses.present?
					  json.addresses customer_que.customer.addresses do |address|
					    json.extract! address, :id, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude
					  end   
					end  
				end
			end
		end
	end
end