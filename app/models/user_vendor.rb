class UserVendor < ActiveRecord::Base
  attr_accessible :recurtion_type, :user_id, :vendor_id, :visit_date, :duration, :recorded_at

  #Model Relation
  belongs_to :user
  belongs_to :vendor
  
  #Model callback
  #after_create :update_section

  # Model validations
  validates :user_id, :presence => true
  #validates :vendor_id, :presence => true
  validates :visit_date, :presence => true
  belongs_to :vendor
  

  #Model scope
  scope :by_date, lambda { |date| where(["visit_date = ?",date]) }
  scope :by_user, lambda{|user| where(["user_vendors.user_id =?",user])}
  scope :by_vendor, lambda{|vendor|(["vendor_id =?",vendor])}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      initialized = (attributes || {}).stringify_keys 
      if !initialized.key?('recorded_at')
        self.recorded_at = Time.now.utc
      else
        self.recorded_at = self.recorded_at.utc
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      user = User.find_by_email(row["Email"])
      date = row["Visit_date"].to_date
      # unless UserVendor.where("user_id=? and vendor_id=? and visit_date=?",user.id,row["Vendor_id"],date).exists?
      #   user_vendor = UserVendor.new
      #   user_vendor.attributes = {:user_id=>user.id, :vendor_id=>row["Vendor_id"] , :visit_date=>date}
      #   user_vendor.save
      # end
      if row["Recursion_rule"].present? and row["Duration"].present?
        create_user_vendor(user.id,row["Vendor_id"],date)
        recursive_allocation(row["Visit_date"],row["Duration"],user.id,row["Vendor_id"],row["Recursion_rule"])
      else
        create_user_vendor(user.id,row["Resource_id"],date)
      end
    end
  end

  def self.recursive_allocation(visit_date,duration,user_id,vendor_id,recursion_rule)
    puts "recursive allocations"
    i=1
    dte = Date.parse visit_date
    case recursion_rule
    when "1"
      while(i<duration.to_i)
        dte= dte+1.days
        create_user_vendor(user_id,vendor_id,dte)
        i+=1
      end
    when "2"
      while(i<duration.to_i)
        dte= dte+2.days
        create_user_vendor(user_id,vendor_id,dte)
        i+=1
      end
    when "3"
      while(i<duration.to_i)
        dte= dte+7.days
        create_user_vendor(user_id,vendor_id,dte)
        i+=1
      end
    when "4"
      while(i<duration.to_i)
        dte= dte+14.days
        create_user_vendor(user_id,vendor_id,dte)
        i+=1
      end
    when "5"
      while(i<duration.to_i)
        dte= dte+1.months
        create_user_vendor(user_id,vendor_id,dte)
        i+=1
      end
    when "6"
      while(i<duration.to_i)
        dte= dte+1.years
        create_user_vendor(user_id,vendor_id,dte)
        i+=1
      end
    else
      puts "something else"
      puts recursion_rule
    end
  end
  def self.create_user_vendor(user_id, vendor_id,visit_date)
    puts "creatig user vendor"
    unless UserVendor.where("user_id=? and vendor_id=? and visit_date=?",user_id,vendor_id,visit_date).exists?
      user_vendor  = UserVendor.create(:user_id=>user_id , :vendor_id=> vendor_id , :visit_date=>visit_date)
      user_vendor.save
    end
  end

  def self.generate_sample_csv(csv_data)
    CSV.generate do |csv|
      csv_header = ["Email","Vendor_id","Visit_date","Recursion_rule","Duration"]
      csv<<csv_header
      csv_data.each do |row_data|
        _row=Array.new
        _row.push(row_data.user.email)
        _row.push(row_data.vendor_id)
        _row.push(row_data.visit_date)
        _row.push("")
        _row.push("")
        csv<<_row
      end
    end
  end
end
