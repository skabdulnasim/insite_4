class Ability
  include CanCan::Ability

  # def initialize(user)
  #   can :manage, :all
  #   user.role.permissions.each do |permission|
  #     if permission.subject_class == "all"
  #       can permission.action.to_sym, permission.subject_class.to_sym
  #     else
  #       can permission.action.to_sym, permission.subject_class.constantize
  #     end
  #   end
  # end

  def initialize(user, controller_namespace)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # New authorization code
    # *******************************************************
    user ||= User.new # guest user (not logged in)
    if user.role.present?
      can :manage, :all
      if (user.role.capabilities).present?
        _namespace = controller_namespace.present? ? controller_namespace : "default"
        _auths = JSON.parse(user.role.capabilities)
        _auths[_namespace].map { |au| eval(au) } if _auths.is_a?(Hash) and _auths[_namespace].present?
      end
    else
      can :read, :all #For not logged in users
    end
  end
end
