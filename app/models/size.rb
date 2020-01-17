class Size < ActiveRecord::Base
  attr_accessible :name, :code

  # Model Validations
  #validates :code, :uniqueness => true
  
  # Model Scopes
  scope :filter_by_name, lambda { |size| where(["lower(name) LIKE (?)", "%#{size.downcase}%"]) }
  
  def self.size_not_in(_arr)
    where('id NOT IN(?)',_arr) 
  end

end
