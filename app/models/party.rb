class Party < ActiveRecord::Base
  attr_accessible :date_time, :name, :owner_id, :party_type, :unique_code

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('unique_code')
        self.unique_code = SecureRandom.hex(3)
      end
      if !initialized.key?('date_time')
        self.date_time = Time.now.utc
      else
        self.date_time = self.date_time.utc
      end
    end
  end

  #Model association
  belongs_to :customer, :class_name => "Customer", :foreign_key => "owner_id"
  has_many :guests
end
