class ResourceProductStock < ActiveRecord::Base
  attr_accessible :product_id, :recorded_at, :resource_id, :stock, :user_id
  # Model validation
  validates :product_id,   :presence => true
  validates :resource_id,  :presence => true
  validates :stock,        :presence => true
  validates :user_id,      :presence => true
  # Model Relation
  belongs_to :resource
  belongs_to :product
  belongs_to :user
end
