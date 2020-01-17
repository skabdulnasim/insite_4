class CancelationPolicy < ActiveRecord::Base
  attr_accessible :cancelation_charge, :cancelation_charge_type, :cancelation_not_allowed_state, :cancellation_allowed, :is_delivery_charge_refandable, :is_refundable, :plolicy, :refund_in, :unit_id, :cancelation_allowed_since_deliverable, :cancelation_causes_attributes

  # Model Relations
  has_many :cancelation_causes, dependent: :delete_all

  accepts_nested_attributes_for :cancelation_causes, allow_destroy: true
end