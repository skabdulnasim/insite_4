class LiveMapConnection < ActiveRecord::Base
  self.abstract_class = true
  establish_connection("live_map_database")
end