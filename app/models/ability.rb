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

    # For all roles, transitions are possible if the state machine allows them
    # (can_foo?) and if the role is authorized (allow_foo?)
    machines = [TravelSponsorship, Reimbursement, Shipment]
    machines.each do |machine|
      machine.transitions.each do |action|
        can action, machine do |m|
          # requesters must, in addition, own the state machine
          if role == "requester"
            m.user == user && m.send("can_#{action}?") && m.send("allow_#{action}?", role)
          else
            m.send("can_#{action}?") && m.send("allow_#{action}?", role)
          end
        end
      end
    end


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

      # TravelSponsorships
      can :create, TravelSponsorship do |r|
        r.event && r.event.accepting_requests?
      end
      can :create, RequestExpense do |e|
        e.request && e.request.editable? && e.request.user == user
      end
      can :read, TravelSponsorship, :user_id => user.id
      can :update, TravelSponsorship do |r|
        r.user == user && r.editable?
      end
      can :destroy, TravelSponsorship do |r|
        r.user == user && r.can_be_destroyed?
      end

      # Reimbursements
      can :create, Reimbursement do |r|
        r.request.user == user && r.request.can_have_reimbursement?
      end
      can :read, Reimbursement, :user_id => user.id
      can :update, Reimbursement do |r|
        r.user == user && r.editable?
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

      # TravelSponsorships
      can :read, TravelSponsorship

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
      can :read, TravelSponsorship

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

      # TravelSponsorships
      can :read, TravelSponsorship

      # Reimbursements
      can :read, Reimbursement

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

      # TravelSponsorships
      can :read, TravelSponsorship
      # Can create state adjustments
      can :adjust_state, TravelSponsorship

      # Reimbursements
      can :read, Reimbursement
      # Can create state adjustments
      can :adjust_state, Reimbursement

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount
      # Reimbursement's payments
      can :read, Payment

      # Shipments
      can :read, Shipment
      # Or even create state adjustments
      can :adjust_state, Shipment

      # Comments
      can [:read, :create], Comment

      # Expenses Reports
      can :read, ExpenseReport

    #
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

      # Comments
      can :read, Comment, Comment.for_role(role) do |c|
        c.for_role? role
      end
    end
  end
end
