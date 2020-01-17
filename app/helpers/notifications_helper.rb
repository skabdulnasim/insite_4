module NotificationsHelper
	def stock_expiry_notifications
		puts "inside the method"
		return Notification.set_type('inventory_stock_expire').set_notification_source_type('Stock').is_unread.joins(:stock).merge(Stock.where('expiry_date >=(?)',Date.today))
	end
end