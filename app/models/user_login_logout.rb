class UserLoginLogout < ActiveRecord::Base
  attr_accessible :user_role_name, :unit_id, :unit_name, :sign_in_at, :sign_out_at, :user_id, :device_identity

  # Model Scopes
  scope :by_date_range, lambda {|from_date,upto_date|where(["created_at BETWEEN ? AND ?", from_date,upto_date])}
  scope :by_device_identity, lambda {|device_identity| where ([ "device_identity = ?", device_identity ])}
  scope :by_user_id, lambda {|user_id| where (["user_id = ?", user_id])}
  scope :set_unit_in, lambda {|unit_id| where (["unit_id in (?)", unit_id])}
  scope :by_role_name, lambda {|user_role_name| where (["user_role_name = ?", user_role_name])}

  # Model Relations
  belongs_to :user



  #Data export to CSV
  def self.by_date_user_login_logouts_to_csv(login_details,from_datetime,to_datetime)
  	CSV.generate do |csv|
  		_pref = ["Role","Name","Email","Unit","Sign in at","Sign out at"]
  		_pref_humanize = _pref.map{|x| (x.humanize)}
  		csv << _pref_humanize
  		login_details.each do |lg_details|
  			_row = Array.new
  			_row.push(lg_details.user_role_name.humanize)
  			_row.push(lg_details.user.profile.firstname + " " + lg_details.user.profile.lastname)
  			_row.push(lg_details.user.email)
        _row.push(lg_details.user.unit.unit_name)
  			_row.push(lg_details.sign_in_at.strftime("%Y-%b-%d %I:%M%p"))
  			_row.push(lg_details.sign_out_at.present? ? lg_details.sign_out_at.strftime("%Y-%b-%d %I:%M%p") : "-")
  			csv << _row
  		end
  	end
  end
 
end
