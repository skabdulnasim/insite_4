class Subdomain < CasConnection
  # attr_accessible :title, :body
  attr_accessible :auth_key, :client_id, :devices, :domain_id, :name, :schema_name, :url, :properties, :status, :valid_from, :valid_till
  has_and_belongs_to_many :members
  has_many :dm_inits

  serialize :properties, Hash
  
end
