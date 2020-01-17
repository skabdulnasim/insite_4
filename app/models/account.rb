class Account < ActiveRecord::Base
  RESTRICTED_SUBDOMAINS = %w(www)
  attr_accessible :subdomain, :user_id, :timezone
  belongs_to :user

  #validates :user_id, presence: true
  validates :subdomain, presence: true,
                        uniqueness: { case_sensitive: false},
                        format: { with: /\A[\w\-]+\Z/i, message: 'Contails invalid characters'},
                        exclusion: { in: RESTRICTED_SUBDOMAINS, message: 'restricted'}
  before_validation :downcase_subdomain
  
  scope :by_subdomain, lambda {|subdomain|where(["subdomain=?", subdomain])}
  
  private
    def downcase_subdomain
      self.subdomain = subdomain.try(:downcase)
    end
end
