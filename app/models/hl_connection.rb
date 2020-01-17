class HlConnection < ActiveRecord::Base
  self.abstract_class = true
  establish_connection("hl_database")
end
