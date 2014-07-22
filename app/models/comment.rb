#
# Comment attached to a state machine
# Comments can be private (not visible by the requester) -in order to be used
# for discussing the final decision- or public -allowing two way communication
# with the requester-.
#
class Comment < ActiveRecord::Base
  # The associated state machine (request, reimbursement...)
  belongs_to :machine, :polymorphic => true, :inverse_of => :comments
  # The author of the note
  belongs_to :user

  validates :body, :user_id, :machine, :presence => true
  validates_inclusion_of :private, :in => [true, false]

  after_create :notify_creation
  after_initialize :set_default_attrs, :if => :new_record?

  # The precision of 'created_at' is one second. For comments in the same second
  # we must use the id for fine-tuning
  scope :oldest_first, -> { order("created_at asc, id asc") }
  scope :newest_first, -> { order("created_at desc, id desc") }
  scope :public, -> {where(:private => false) }
  # For access control
  # TODO: needs heavy refactoring https://progress.opensuse.org/issues/2810
  scope :for_role, lambda {|role|
    conds = []
    args = []
    ROLES.each do |k, v|
      conds 
      if v[:private].include? role
        conds << "(requests.type = ? OR machine_type = ?)"
        args += [k.to_s.camelize]*2
      elsif v[:public].include? role
        conds << "((requests.type = ? OR machine_type = ?) AND public = ?)"
        args += [k.to_s.camelize]*2 + [true]
      end
    end
    j = "LEFT JOIN requests on requests.id = comments.machine_id AND comments.machine_type = 'Request'"
    joins(j).where([conds.join(" OR ")] + args) }

  ROLES = {
    :travel_sponsorship => {:public => [:administrative], :private => [:tsp, :assistant]},
    :reimbursement      => {:public => [:administrative], :private => [:tsp, :assistant]},
    :shipment           => {:public => [:shipper], :private => [:material]} }

  # List of roles with access to private comments
  #
  # @param [#to_s]  klass  class of the commented object
  # @return [Array] Only tsp or assistant
  def self.private_roles(klass)
    ROLES[klass.to_s.underscore.to_sym][:private]
  end

  # Checks if the provided role have access to private comments
  #
  # @param [#to_s]  klass  class of the commented object
  # @param [#to_sym] role Name of the role
  # @return [Boolean] true if the role is allowed
  def self.private_role?(role, klass)
    private_roles(klass).include? role.to_sym
  end

  # Hint about the private field
  #
  # @param [#to_s]  klass  class of the commented object
  # @return [String] a text explaining the meaning of the private field in
  def self.private_hint(klass)
    I18n.t(:comment_private_hint, roles: private_roles(klass).to_sentence)
  end

  # Checks if the comment is public
  #
  # @return [Boolean] true is private is false (pretty obvious)
  def public?
    !self.private
  end

  # Checks if the comment is accessible to users of a given role
  #
  # @param [#to_s] role  role to check
  # @return [Boolean] true if readable by all users of the role
  def for_role?(role)
    roles = ROLES[machine.class.model_name.singular.to_sym]
    if roles[:private].include? role.to_sym
      true
    elsif roles[:public].include? role.to_sym
      self.public?
    else
      false
    end
  end

  # Sets the machine type when assigning the association.
  #
  # Needed in order to STI and polymorphic assotiations to work together
  # according to
  # http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
  def machine_type=(class_name)
    super(class_name.constantize.base_class.to_s)
  end

  protected

  # Notify creation to involved users
  #
  # If the comment is private, 'involved users' means those with the proper
  # role + supervisors that have previously commented
  #
  # If the comment is public, it means: requester + users with the tsp or
  # assistant roles + users with the role designed using the macro method
  # assign_state + users that have already commented
  def notify_creation
    people = Comment.private_roles(machine.class)
    if private
      people += machine.comments.includes(:user).map(&:user).select {|u| u.profile.role_name == "supervisor"}.uniq
    else
      people += [machine.user] + machine.assigned_roles - [:requester]
      people += machine.comments.includes(:user).map(&:user).uniq
    end
    CommentMailer.notify_to people.uniq, :creation, self
  end

  def set_default_attrs
    self.private = false if self.private.nil?
  end
end
