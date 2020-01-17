class LiveMapPoint < LiveMapConnection
	attr_accessible :id, :user_id, :latitude, :longitude, :duration, :recorded_at, :subdomain

	belongs_to :user
end