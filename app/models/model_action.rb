class ModelAction < ActiveRecord::Base
  attr_accessible :master_model_id, :name, :status, :reason_codes_attributes
  # Model Relations
  has_many :reason_codes, dependent: :delete_all
  belongs_to :master_model
  
  accepts_nested_attributes_for :reason_codes, allow_destroy: true
end
