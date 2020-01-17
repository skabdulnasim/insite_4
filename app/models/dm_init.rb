class DmInit < CasConnection
  attr_accessible :device_id, :service_id, :user_id, :subdomain_id

  belongs_to :subdomain
  
  scope :set_id, lambda {|id|where(["id=?", id])}
  scope :set_subdomain, lambda {|s_id|where(["subdomain_id=?", s_id])}
  scope :active_device, lambda { where(:status => 1) }
  scope :inactive_device, lambda { where(:status => 2) }
end
