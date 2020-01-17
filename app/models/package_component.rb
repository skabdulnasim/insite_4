class PackageComponent < ActiveRecord::Base
  attr_accessible :basic_unit_id, :category_id, :name

  def self.name_for(prefix)
    components = where("lower(name) LIKE ?", "#{prefix.downcase}%")
    components.order("id desc").limit(10)
  end
end