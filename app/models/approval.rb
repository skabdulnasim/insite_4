class Approval < ActiveRecord::Base
  attr_accessible :approvable_id, :approvable_type, :is_approve, :role_id, :user_id, :reason

  belongs_to :approvable, :polymorphic => true
  belongs_to :user
  belongs_to :role

  after_create :create_approval_notification

  scope :filter_by_approvable_type, lambda{|approvable_type| where("approvable_type = ?", approvable_type)}
  scope :filter_by_is_approve, lambda{|is_approve| where("is_approve = ?", is_approve)}
  
  def create_approval_notification
  	Notification.new_role_notification("PO approval","You have a purchase order approval.","inventory","/notifications/approval_alerts",self.role_id,nil,'high')
  end
end
