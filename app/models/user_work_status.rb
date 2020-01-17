class UserWorkStatus < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :recorded_at, :remarks, :user_id, :work_status, :device_id
  
  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end  

  WORKSTATUS = %w(Leave Half_day_leave Visit_with_manager Others)

  validates :recorded_at,     :presence => true
  validates :user_id,     :presence => true
  validates :work_status,     :presence => true
  # => Dynamic methods for bill statuses
  WORKSTATUS.each do |work_status|
    define_method "#{work_status}?" do
      self.work_status == work_status
    end
  end

  #Model Scope
  scope :by_user, lambda { |user_id| where(["user_id = ?",user_id]) }

  def self.by_recorded_at(from_date, upto_date)
    where('recorded_at BETWEEN ? AND ?',from_date,upto_date)
  end
end
