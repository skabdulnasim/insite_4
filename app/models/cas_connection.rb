class CasConnection < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "cas_database"
end
