class Boxing < ActiveRecord::Base
  attr_accessible :name, :boxing_source_type, :boxing_source_id, :store_id

  # Model Relations
  has_many :boxes
  belongs_to :boxing_source, polymorphic: true
  belongs_to :store
  BOXING_SOURCE_TYPE = %w(Package)
end