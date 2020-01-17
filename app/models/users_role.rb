class UsersRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  attr_accessible :user_id, :role_id
  scope :find_by_role, lambda { |role| where(["role_id = ?",role]) }
  scope :set_role_in, lambda {|role_ids| where(["role_id in (?)", role_ids])}
  scope :by_role_name, lambda { |role_name| joins(:roles).merge(Role.by_role_name(role_name))}
end
