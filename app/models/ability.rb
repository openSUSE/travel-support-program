class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    can :manage, User, :id => user.id
    can :manage, UserProfile, :user_id => user.id
    can [:read, :create], Event
    role = user.find_profile.role_name

    #
    # Requesters (regular users) permissions
    # --------------------------------------
    #
    if role == "requester"
      # Events
      can :update, Event do |e|
        e.editable_by_requesters?
      end
      can :destroy, Event do |e|
        e.editable_by_requesters? && e.can_be_destroyed?
      end

      # Requests
      can :create, Request
      can :read, Request, :user_id => user.id
      can :update, Request do |r|
        r.user == user && r.editable_by_requester?
      end
      can :destroy, Request do |r|
        r.user == user && r.can_be_destroyed?
      end
      # Requester can accept, submit or cancel his own requests, but only when
      # state_machines allows to do it
      [:accept, :reject, :cancel].each do |action|
        can action, Request do |r|
          r.user == user && r.send("can_#{action}?")
        end
      end
      can :submit, Request do |r|
          r.user == user && r.can_submit? && !r.expenses.empty?
      end

      # Reimbursements
      can :create, Reimbursement, :request => {:user_id => user.id}
      can :read, Reimbursement, :user_id => user.id
      can :update, Reimbursement do |r|
        r.user == user && r.editable_by_requester?
      end
      [:submit, :confirm, :cancel].each do |action|
        can action, Reimbursement do |r|
          r.user == user && r.send("can_#{action}?")
        end
      end
    #
    # TSP members permissions
    # -----------------------
    #
    elsif role == "tsp"
      # User profiles
      can :read, UserProfile

      # Events
      can [:update, :validate], Event
      can :destroy, Event do |e|
        e.can_be_destroyed?
      end

      # Requests
      can :read, Request
      # TSP members can approve, reject or cancel any request, but only when
      # state_machines allows to do it
      [:approve, :reject, :cancel].each do |action|
        can action, Request do |r|
          r.editable_by_tsp? && r.send("can_#{action}?")
        end
      end

      # Reimbursements
      can :read, Reimbursement
      [:approve, :reject, :cancel].each do |action|
        can action, Reimbursement do |r|
          r.editable_by_tsp? && r.send("can_#{action}?")
        end
      end
      can :complete, Reimbursement do |r|
        r.can_complete?
      end
    #
    # Administratives permissions
    # -----------------------
    #
    elsif role == "administrative"
      # User profiles
      can :read, UserProfile

      # Requests
      can :read, Request

      # Reimbursements
      can :read, Reimbursement
      can :update, Reimbursement do |r|
        r.editable_by_administrative?
      end
      can :authorize, Reimbursement do |r|
        r.editable_by_administrative? && r.can_authorize?
      end
      [:authorize, :reject].each do |action|
        can action, Reimbursement do |r|
          r.editable_by_administrative? && r.send("can_#{action}?")
        end
      end
      can :complete, Reimbursement do |r|
        r.can_complete?
      end
    end
  end
end
