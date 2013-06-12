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
        e.request && e.request.editable_by_requester? && e.request.user == user
      end
      can :read, Request, :user_id => user.id
      can :update, Request do |r|
        r.user == user && r.editable_by_requester?
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
        r.user == user && r.editable_by_requester?
      end
      [:submit, :cancel].each do |action|
        can action, Reimbursement do |r|
          r.user == user && r.send("can_#{action}?")
        end
      end

      # Reimbursement's attachments
      can :read, ReimbursementAttachment do |a|
        a.reimbursement.user == user
      end
      can [:create, :update, :destroy], ReimbursementAttachment do |a|
        a.reimbursement.user == user && a.reimbursement.editable_by_requester?
      end

      # Reimbursement's bank account
      can :read, BankAccount do |a|
        a.reimbursement.user == user
      end
      can [:create, :update], BankAccount do |a|
        a.reimbursement.user == user && a.reimbursement.editable_by_requester?
      end

      # Final notes
      can :read, FinalNote do |n|
        n.machine.user == user
      end
      can :create, FinalNote do |n|
        n.machine.user == user && n.machine.can_have_final_notes?
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
      can :update, Request do |r|
        r.editable_by_tsp?
      end
      # TSP members can approve, roll back or cancel any request, but only when
      # state_machines allows to do it
      [:approve, :roll_back, :cancel].each do |action|
        can action, Request do |r|
          r.send("can_#{action}?")
        end
      end

      # Reimbursements
      can :read, Reimbursement
      can :update, Reimbursement do |r|
        r.editable_by_tsp?
      end
      can :cancel, Reimbursement do |r|
        r.can_cancel?
      end
      [:approve, :roll_back].each do |action|
        can action, Reimbursement do |r|
          r.send("can_#{action}?") && r.tsp_pending?
        end
      end

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount

      # Final notes
      can :read, FinalNote
      can :create, FinalNote do |n|
        n.machine.can_have_final_notes?
      end

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
      [:authorize, :roll_back].each do |action|
        can action, Reimbursement do |r|
          r.send("can_#{action}?") && r.tsp_approved?
        end
      end

      # Reimbursement's attachments
      can :read, ReimbursementAttachment
      # Reimbursement's bank account
      can :read, BankAccount

      # Final notes
      can :read, FinalNote

    end
  end
end
