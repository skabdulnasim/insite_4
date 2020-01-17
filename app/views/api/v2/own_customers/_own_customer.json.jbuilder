json.extract! own_customer, :id, :name, :email, :mobile_no, :customer_unique_id
json.address do
  json.extract! @own_customer.own_customer_addresses.last, :id, :landmark, :city, :state, :pincode, :contact_no, :latitude, :longitude
end 
json.customer_queues do
  json.extract! @own_customer.customer_queues.last, :id, :pax, :total_pax
  json.from_date @own_customer.customer_queues.last.from_date.strftime("%d-%m-%Y, %I:%M %p")
  json.to_date @own_customer.customer_queues.last.to_date.strftime("%d-%m-%Y, %I:%M %p")
end 

