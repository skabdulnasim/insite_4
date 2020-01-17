class BillDestination < ActiveRecord::Base
  attr_accessible :bill_footer, :bill_header, :name, :unit_id
end
