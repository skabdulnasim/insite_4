class UserResource < ActiveRecord::Base
  #include DateLimit
  attr_accessible :day, :resource_id, :user_id, :visit_date
  # Model validations
  validates :user_id, :presence => true
  #validates :resource_id, :presence => true
  audited
  # Model relations
  belongs_to :user
  belongs_to :resource

  # => Model scopes
  scope :by_day,                        lambda { |day| where(["day = ?",day]) }
  scope :by_user,                       lambda{|user| where(["user_resources.user_id =?",user])}
  scope :by_users,                       lambda{|users| where(["user_resources.user_id IN (?)",users])}
  scope :by_date,                       lambda { |date| where(["visit_date = ?",date]) }
  scope :fetch_duplicate_allocation,    lambda {|user_id,resource_id,date| where('user_resources.user_id = ? AND user_resources.resource_id = ? AND user_resources.visit_date = ?',user_id, resource_id, date)}
  scope :by_date_range,       lambda {|from_date, upto_date|where('visit_date BETWEEN ? AND ?',from_date,upto_date)}
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user = User.find_by_email(row["Email"])
      resource= Resource.find(row["Resource_id"])
      date = row["Visit_date"].to_date
      if row["Recursion_rule"].present? and row["Duration"].present?
        create_user_resource(user.id,row["Resource_id"],date)
        recursive_allocation(row["Visit_date"],row["Duration"],user.id,row["Resource_id"],row["Recursion_rule"])
      else
        create_user_resource(user.id,row["Resource_id"],date)
      end
    end
  end
  
  def self.recursive_allocation(visit_date,duration,user_id,resource_id,recursion_rule)
    i=1
    puts duration
    dte = Date.parse visit_date
    case recursion_rule
    when "1"
      while(i<duration.to_i)
        dte= dte+1.days
      create_user_resource(user_id,resource_id,dte)
        i+=1
      end
    when "2"
      while(i<duration.to_i)
        dte= dte+2.days
      create_user_resource(user_id,resource_id,dte)
        i+=1
      end
    when "3"
      while(i<duration.to_i)
        dte= dte+7.days
      create_user_resource(user_id,resource_id,dte)
        i+=1
      end
    when "4"
      while(i<duration.to_i)
        dte= dte+14.days
      create_user_resource(user_id,resource_id,dte)
        i+=1
      end
    when "5"
      while(i<duration.to_i)
        dte= dte+1.months
      create_user_resource(user_id,resource_id,dte)
        i+=1
      end
    when "6"
      while(i<duration.to_i)
        dte= dte+1.years
      create_user_resource(user_id,resource_id,dte)
        i+=1
      end
    else
      puts "something else"
    end
  end

  def self.create_user_resource(user_id, resource_id,visit_date)
    unless UserResource.where("user_id=? and resource_id=? and visit_date=?",user_id,resource_id,visit_date).exists?
      user_resource  = UserResource.create(:user_id=>user_id , :resource_id=> resource_id , :visit_date=>visit_date)
      user_resource.save
    end
  end 

  def self.sample_csv(csv_data)
    CSV.generate do |csv|
      csv_header = ["Email","Resource_id","Visit_date","Recursion_rule","Duration"]
      csv<<csv_header
      csv_data.each do |row_data|
        _row=Array.new
        _row.push(row_data.user.email)
        _row.push(row_data.resource_id)
        _row.push(row_data.visit_date)
        _row.push("")
        _row.push("")
        csv<<_row
      end
    end
  end
end
