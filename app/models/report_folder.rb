class ReportFolder < ActiveRecord::Base
  attr_accessible :master_model, :name, :related_models,:attributes_accessible
  has_many :reports
  has_many :custom_reports
  serialize :related_models, Array
  
  def self.master_models
   _data = Dir.glob("#{Rails.root}/app/models/*.rb").collect{|name| File.basename(name,".rb")}.sort
   #_data = Dir.foreach("#{Rails.root}/app/models/").select{ |type| type.include?".rb" }.collect{|name| File.basename(name, ".rb")}.sort
   _data = _data.collect{|entry| {id: entry, name: entry.humanize}}
  end

  def self.relational_models(master_model)
    master_model.to_s.classify.constantize.reflect_on_all_associations.map(&:name).collect{|entry| {id: entry.to_s, name: entry.to_s.humanize}}

  end
end
