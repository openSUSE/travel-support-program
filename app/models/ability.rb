#
# CanCan permissions
#
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
      can :create, Request do |r|
        r.event && r.event.accepting_requests?
      end
      can :create, RequestExpense do |e|
        e.request && e.request.editable? && e.request.user == user
      end
      can :read, Request, :user_id => user.id
      can :update, Request do |r|
        r.user == user && r.editable?
      end
      can :destroy, Request do |r|
        r.user == user && r.can_be_destroyed?
      end
      # Requester can manage his own requests, but only in the way that
      # state_machine allows to do it
      [:accept, :submit, :roll_back, :cancel].each do |action|
        can action, Request do |r|
          r.user == user && r.send("can_#{action}?")
        end
      end

      # Reimbursements
      can :create, Reimbursement do |r|
        r.request.user == user && r.request.can_have_reimbursement?
      end
      can :read, Reimbursement, :user_id => user.id
      can :update, Reimbursement do |r|
        r.user == user && r.editable?
      end
      [:submit, :roll_back, :cancel].each do |action|
        can action, Reimbursement do |r|
          r.user == user && r.send("can_#{action}?")
        end
      end

      # Reimbursement's attachments
      can :read, ReimbursementAttachment do |a|
        a.reimbursement.user == user
      end
      can [:create, :update, :destroy], ReimbursementAttachment do |a|
        a.reimbursement.user == user && a.reimbursement.editable?
      end

      # Reimbursement's bank account
      can :read, BankAccount do |a|
        a.reimbursement.user == user
      end
      can [:create, :update], BankAccount do |a|
        a.reimbursement.user == user && a.reimbursement.editable?
      end

      # Reimbursement's payments
      can :read, Payment, :reimbursement => {:user_id => user.id}

      # Shipments
      can :create, Shipment do |s|
        s.event && s.event.accepting_shipments?
      end
      can :read, Shipment, :user_id => user.id
      can :update, Shipment do |s|
        s.user == user && s.editable?
      end
      can :destroy, Shipment do |s|
        s.user == user && s.can_be_destroyed?
      end
      # Requester can manage his own shipments, but only in the way that
      # state_machine allows to do it
      [:request, :roll_back, :confirm, :cancel].each do |action|
        can action, Shipment do |s|
          s.user == user && s.send("can_#{action}?")
        end
      end

      # Comments
      # Allows fetching other user's comments, but is not a real problem with
      # the current implementation (comments are always fetched in the scope
      # of a request or reimbursement)
      can [:read, :create], Comment, Comment.public do |c|
        c.machine.user == user && c.public?
      end

      # Expenses Reports
      can :read, ExpenseReport, ExpenseReport.related_to(user) do |e|
          e.related_to(user)
      end

    #
    # TSP members permissions
    # -----------------------
    #
    elsif role == "tsp"
      # User profiles
      can :read, UserProfile

      # Budgets
      can :manage, Budget

      # Events
      can [:update, :validate], Event
      can :destroy, Event do |e|
        e.can_be_destroyed?
      end

      # Requests
      can :read, Request
      can :cancel, Request do |r|
        r.cancelable_by_tsp?
      end
      # TSP members can approve and roll back any request, but only when
      # state_machines allows to do it
      [:approve, :roll_back].each do |action|
        can action, Request do |r|
          r.send("can_#{action}?")
        end
      end

      # Reimbursements
      can :read, Reimbursement
      can :cancel, Reimbursement do |r|
        r.cancelable_by_tsp?
      end
      [:approve, :roll_back].each do |action|
        can action, Reimbursement do |r|
          r.send("can_#{action}?")
        end
      end

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount
      # Reimbursement's payments
      can :read, Payment

      # Comments
      can [:read, :create], Comment, Comment.for_role(role) do |c|
        c.for_role? role
      end

      # Expenses Reports
      can :read, ExpenseReport

    #
    # TSP assistants permissions
    # --------------------------
    #
    elsif role == "assistant"
      # User profiles
      can :read, UserProfile

      # Budgets
      can :read, Budget

      # Events (same permissions as requesters)
      can :update, Event do |e|
        e.editable_by_requesters?
      end
      can :destroy, Event do |e|
        e.editable_by_requesters? && e.can_be_destroyed?
      end

      # Requests
      can :read, Request

      # Reimbursements
      can :read, Reimbursement

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount
      # Reimbursement's payments
      can :read, Payment

      # Comments
      can [:read, :create], Comment, Comment.for_role(role) do |c|
        c.for_role? role
      end

      # Expenses Reports
      can :read, ExpenseReport

    #
    # Administratives permissions
    # -----------------------
    #
    elsif role == "administrative"
      # Events
      can :update, Event do |e|
        e.editable_by_requesters?
      end
      can :destroy, Event do |e|
        e.editable_by_requesters? && e.can_be_destroyed?
      end

      # User profiles
      can :read, UserProfile

      # Requests
      can :read, Request

      # Reimbursements
      can :read, Reimbursement
      [:process, :roll_back, :confirm].each do |action|
        can action, Reimbursement do |r|
          r.send("can_#{action}?")
        end
      end

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount
      # Reimbursement's payments
      can [:read, :create, :update, :destroy], Payment

      # Comments
      can :read, Comment, Comment.for_role(role) do |c|
        c.for_role? role
      end

    #
    # Supervisors permissions
    # --------------------------------------
    #
    elsif role == "supervisor"
      # User profiles
      can :read, UserProfile

      # Budgets
      can :manage, Budget

      # Events
      can [:update, :validate], Event
      can :destroy, Event do |e|
        e.can_be_destroyed?
      end

      # Requests
      can :read, Request
      # Supervisors can cancel any request, if possible
      can :cancel, Request do |r|
        r.can_cancel?
      end
      # Or even create state adjustments
      can :adjust_state, Request

      # Reimbursements
      can :read, Reimbursement
      # Supervisors can cancel any reimbursement, if possible
      can :cancel, Reimbursement do |r|
        r.can_cancel?
      end
      # Or even create state adjustments
      can :adjust_state, Reimbursement

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount
      # Reimbursement's payments
      can :read, Payment

      # Requests
      can :read, Shipment
      # Supervisors can cancel any shipment, if possible
      can :cancel, Shipment do |s|
        s.can_cancel?
      end
      # Or even create state adjustments
      can :adjust_state, Shipment

      # Comments
      can [:read, :create], Comment

      # Expenses Reports
      can :read, ExpenseReport

    #
    # admin permissions
    # --------------------------
    #
    elsif role == "admin"
      can :manage, State
      can :manage, TransitionEvent

    # Material manager permissions
    # ----------------------------
    #
    elsif role == "material"
      # User profiles
      can :read, UserProfile

      # Events
      can [:update, :validate], Event
      can :destroy, Event do |e|
        e.can_be_destroyed?
      end

      # Shipments
      can :read, Shipment
      can :cancel, Shipment do |s|
        s.can_cancel?
      end
      # Material managers can approve and roll back any shipment,
      # but only when state_machines allows to do it
      [:approve, :roll_back].each do |action|
        can action, Shipment do |s|
          s.send("can_#{action}?")
        end
      end

      # Comments
      can [:read, :create], Comment, Comment.for_role(role) do |c|
        c.for_role? role
      end

    #
    # Shipper permissions
    # -------------------
    #
    elsif role == "shipper"
      # Events
      can :update, Event do |e|
        e.editable_by_requesters?
      end
      can :destroy, Event do |e|
        e.editable_by_requesters? && e.can_be_destroyed?
      end

      # Shipments
      can :read, Shipment
      # Shippers can dispatch any shipment,
      # but only when state_machines allows to do it
      can :dispatch, Shipment do |s|
        s.can_dispatch?
      end

      # Comments
      can :read, Comment, Comment.for_role(role) do |c|
        c.for_role? role
      end
    end
  end
end
