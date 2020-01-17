class DeveloperApp < ActiveRecord::Base
  attr_accessible :description, :is_active, :name, :website

  validates :name, :presence => true
  validates :app_secret, :presence => true
  validates :app_secret, :presence => true

  before_validation :generate_app_secret

  def self.authenticate app_id, app_secret
    app = DeveloperApp.find(app_id)
    return (app and app.is_active and app.app_secret == Base64.encode64(app_secret)) ? true : false
  end

  def self.filter_by_string(searcing_text)
    if searcing_text.present?
      where("lower(name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end    
  end
  
  private

  def generate_app_secret
    if new_record?
      random_string = SecureRandom.hex
      self.app_secret   = Base64.encode64(random_string)
    end
  end  
end
