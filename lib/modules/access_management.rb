module AccessManagement
  def self.get_number_of_role_users(role_id)
    _role_users = UsersRole.where(:role_id => role_id)
    return _role_users
  end
end