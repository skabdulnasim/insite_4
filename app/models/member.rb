class Member < CasConnection
  # attr_accessible :title, :body
  attr_accessible :email,:encrypted_password, :password, :password_confirmation, :remember_me, :site_url
  has_and_belongs_to_many :subdomains
end
