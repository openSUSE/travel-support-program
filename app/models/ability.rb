#
# CanCan permissions
#
class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    can :manage, User, id: user.id
    can :manage, UserProfile, user_id: user.id
    role = user.find_profile.role_name

    machines = [TravelSponsorship, Reimbursement, Shipment]
    machines.each do |machine|
      # For all roles, transitions are possible if the state machine allows them
      # (can_foo?) and if the role is authorized (allow_foo?)
      machine.transitions.each do |action|
        can action, machine do |m|
          # For own machines, the :requester permissions are applied
          if m.user == user
            m.send("can_#{action}?") && m.send("allow_#{action}?", :requester)
          # For machines belonging to other users, use the role
          else
            # :requester is not longer a valid role
            if role == 'requester'
              false
            else
              m.send("can_#{action}?") && m.send("allow_#{action}?", role)
            end
          end
        end
      end

      # Comments
      conds = { machine_type: machine.base_class.to_s }
      if machine.superclass != ActiveRecord::Base
        conds[:machine] = { type: machine.to_s }
      end

      if machine.allow_private_comments?(role)
        can [:read, :create], Comment, conds
      elsif machine.allow_public_comments?(role)
        can [:read, :create], Comment, conds.merge(private: false)
      end

      requester_conds = conds.deep_dup
      requester_conds[:machine] = {} unless requester_conds[:machine]
      requester_conds[:machine][:user_id] = user.id
      if machine.private_comments_for_requester?
        can [:read, :create], Comment, requester_conds
      elsif machine.public_comments_for_requester?
        can [:read, :create], Comment, requester_conds.merge(private: false)
      end
    end

    #
    # Regular users permissions
    # -------------------------
    #

    # Events
    can [:read, :create], Event
    can :update, Event, &:editable_by_requesters?
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
    can :read, TravelSponsorship, user_id: user.id
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
    can :read, Reimbursement, user_id: user.id
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
    can :read, Payment, reimbursement: { user_id: user.id }

    # Shipments
    can :create, Shipment do |s|
      s.event && s.event.accepting_shipments?
    end
    can :read, Shipment, user_id: user.id
    can :update, Shipment do |s|
      s.user == user && s.editable?
    end
    can :destroy, Shipment do |s|
      s.user == user && s.can_be_destroyed?
    end

    # FIXME: workaround (see below)
    report_full_access = false

    #
    # TSP members permissions
    # -----------------------
    #
    if role == 'tsp'
      # User profiles
      can :read, UserProfile

      # Budgets
      can :manage, Budget

      # Events
      can [:update, :validate, :email, :email_event], Event
      can :destroy, Event, &:can_be_destroyed?

      # TravelSponsorships
      can :read, TravelSponsorship

      # Reimbursements
      can :read, Reimbursement
      can :read, ReimbursementAttachment
      can :read, BankAccount
      can :read, Payment

      # Expenses Reports
      can :read, TravelExpenseReport
      report_full_access = true
    end

    #
    # TSP assistants permissions
    # --------------------------
    #
    if role == 'assistant'
      # User profiles
      can :read, UserProfile

      # Budgets
      can :read, Budget

      # Requests
      can :read, TravelSponsorship

      # Reimbursements
      can :read, Reimbursement
      can :read, ReimbursementAttachment
      can :read, BankAccount
      can :read, Payment

      # Expenses Reports
      can :read, TravelExpenseReport
      report_full_access = true
    end

    #
    # Administratives permissions
    # -----------------------
    #
    if role == 'administrative'
      # User profiles
      can :read, UserProfile

      # TravelSponsorships
      can :read, TravelSponsorship

      # Reimbursements
      can :read, Reimbursement
      can :read, ReimbursementAttachment
      can :read, BankAccount
      can [:read, :create, :update, :destroy], Payment
    end

    #
    # Supervisors permissions
    # --------------------------------------
    #
    if role == 'supervisor'
      # User profiles
      can :read, UserProfile

      # Budgets
      can :manage, Budget

      # Events
      can [:update, :validate], Event
      can :destroy, Event, &:can_be_destroyed?

      # TravelSponsorships
      can :read, TravelSponsorship
      # Can create state adjustments
      can :adjust_state, TravelSponsorship

      # Reimbursements
      can :read, Reimbursement
      can :read, ReimbursementAttachment
      can :read, BankAccount
      can :read, Payment
      # Can create state adjustments
      can :adjust_state, Reimbursement

      # Shipments
      can :read, Shipment
      # Or even create state adjustments
      can :adjust_state, Shipment

      # Comments
      can [:read, :create], Comment

      # Expenses Reports
      can :read, TravelExpenseReport
      report_full_access = true
    end

    #
    # Material manager permissions
    # ----------------------------
    #
    if role == 'material'
      # User profiles
      can :read, UserProfile

      # Events
      can [:update, :validate], Event
      can :destroy, Event, &:can_be_destroyed?

      # Shipments
      can :read, Shipment
    end

    #
    # Shipper permissions
    # -------------------
    #
    if role == 'shipper'
      cannot :create, TravelSponsorship

      # Shipments
      can :read, Shipment
    end

    # FIXME: workaround
    # CanCanCan cannot merge Active Record scope with other conditions
    unless report_full_access
      can :read, TravelExpenseReport, TravelExpenseReport.related_to(user) do |e|
        e.related_to(user)
      end
    end
  end
end
