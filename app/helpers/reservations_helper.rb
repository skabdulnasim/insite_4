module ReservationsHelper
 	def billed_reservation(object)
    if object.bill.present? and object.bill.paid?
      tag("i", class: "mdi-action-done-all smaller", style: "color:#4cae4c", title: "Order billed and settled")
    elsif object.status == "1"
      tag("i", class: "mdi-navigation-check smaller", style: "color:#4cae4c", title: "Order billed")
    end
  end
end
