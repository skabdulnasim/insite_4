json.extract! party, :id, :name, :owner_id, :party_type, :unique_code, :created_at, :updated_at, :date_time
# Add owner details
json.owner do
	json.extract! party.customer, :mobile_no
end
# Add guest details
if party.guests.present?
	json.gustes party.guests do |guest|
		json.extract! guest, :id, :mobile_no
	end
end	