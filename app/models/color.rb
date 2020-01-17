class Color < ActiveRecord::Base
  attr_accessible :name, :code

  # Model Validations
  #validates :code, :uniqueness => true

  # Model Scopes
  scope :filter_by_name, lambda { |color| where(["lower(name) LIKE (?)", "%#{color.downcase}%"]) }

  def self.color_not_in(_arr)
    where('id NOT IN(?)',_arr) 
  end
end
