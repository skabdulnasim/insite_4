class ReservationDetail < ActiveRecord::Base
  attr_accessible :reservation_id, :resource_id, :is_parent, :state

  # Model Relations
  belongs_to :reservation
  belongs_to :resource

  # Model Scopes
  scope :set_resource_ids, lambda {|resource_ids| where(["resource_id in (?)",resource_ids])}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('is_parent')
      	resource = Resource.find(self.resource_id)
        self.is_parent = resource.child_resources.present? ? 'yes' : 'no'
      end                
    end
  end
end