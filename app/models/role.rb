class Role < ActiveRecord::Base
  scopify
  
  # Attribute macros
  attr_accessible :name, :permission_ids, :capabilities, :parent

  # Association macros
  has_one :incentive_rule
  has_many :approvals
  has_many :notifications
  belongs_to :resource, :polymorphic => true
  has_and_belongs_to_many :users, :join_table => :users_roles
  has_and_belongs_to_many :permissions, :join_table => :roles_permissions
  belongs_to :parent_role, :foreign_key => "parent", :class_name => "Role"

  # Validation macros
  validates :name, presence: true
  
  # Callbacks
  before_validation :set_attributes

  #Scope
  scope :by_role_name, lambda{|name| where("name = ?", name)}
  scope :get_root_roles, lambda { where(:parent => nil) }
  # scope :child_roles, lambda {|role_id| {:conditions=>{:parent=>role_id}}} rails 4 comment
  scope :child_roles, lambda {|role_id| where(["parent = ?", role_id])}
  scope :set_role_in, lambda {|role_ids|where(["id in (?)", role_ids])}

  def set_attributes
    self.name = self.name.parameterize.underscore
  end

  def self.filter_by_role_names(role_names)
    if !role_names.empty?
      where('name IN(?)',role_names)
    else
      all
    end
  end

  def self.not_in_role_names(role_names)
    if !role_names.empty?
      where('name NOT IN(?)',role_names)
    else
      all
    end
  end

  def self.role_permission_csv(role)
    CSV.generate do |csv|
      _title = ["Role"]
      AccessManager.where(:controller_status => 1).each do |cls|
        actions = JSON.parse(cls.controller_actions)
        actions.each do |act|
          _title.push(cls.controller_desc+" "+act[1]['action_desc'])
        end
      end
      csv << _title

      role.each do |object|
        _row = Array.new
        _row.push(object.name)

        _role_capabilities = object.capabilities.present? ? object.capabilities : Array.new
        AccessManager.where(:controller_status => 1).each do |cls|     
          _actions = JSON.parse(cls.controller_actions)  
            _actions.each do |act|
              _strng = "cannot :"+act[0]+", "+(cls.controller_alias)
              _check_stat = (_role_capabilities.include? _strng) ? "Not Allowed" : "Allow"
              _row.push(_check_stat)
            end
        end
        csv << _row
      end
      _blank = [""]
      csv << _blank
    end
  end

  def self.has_parent?(role)
    role.parent.nil? ? false : true
  end

end