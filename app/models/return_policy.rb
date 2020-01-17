class ReturnPolicy < ActiveRecord::Base
  attr_accessible :is_delivery_charge_refandable, :is_refundable, :policy, :return_allowed, :return_allowed_after_deliverable, :return_alowed_on_order_state, :return_charge, :return_charge_type, :unit_id, :return_causes_attributes

  # Model Relations
  has_many :return_causes, dependent: :delete_all

  accepts_nested_attributes_for :return_causes, allow_destroy: true
end