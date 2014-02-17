#
# Comment attached to a state machine
# Comments can be private (not visible by the requester) -in order to be used
# for discussing the final decision- or public -allowing two way communication
# with the requester-.
#
class Comment < ActiveRecord::Base
  attr_accessible :body, :private
  # The associated state machine (request, reimbursement...)
  belongs_to :machine, :polymorphic => true, :inverse_of => :comments
  # The author of the note
  belongs_to :user

  validates :body, :user_id, :machine, :presence => true
  validates_inclusion_of :private, :in => [true, false]

  after_create :notify_creation
  after_initialize :set_default_attrs, :if => :new_record?

  scope :oldest_first, -> { order("created_at asc") }
  scope :newest_first, -> { order("created_at desc") }
  scope :public, -> {where(:private => false) }

  # List of roles with access to private comments
  #
  # @return [Array] Only tsp or assistant
  def self.private_roles
    [:tsp, :assistant]
  end

  # Checks if the provided role have access to private comments
  #
  # @param [#to_sym] role Name of the role
  # @return [Boolean] true if the role is allowed
  def self.private_role?(role)
    private_roles.include?(role.to_sym)
  end

  # Hint about the private field
  #
  # @return [String] a text explaining the meaning of the private field in
  def self.private_hint
    I18n.t(:comment_private_hint, roles: private_roles.to_sentence)
  end

  # Checks if the comment is public
  #
  # @return [Boolean] true is private is false (pretty obvious)
  def public?
    !self.private
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
    if private
      people = Comment.private_roles
      people += machine.comments.includes(:user).map(&:user).select {|u| u.profile.role_name == "supervisor"}.uniq
    else
      people = ([machine.user, :tsp, :assistant] + machine.assigned_roles).uniq - [:requester]
      people += machine.comments.includes(:user).map(&:user).uniq
    end
    CommentMailer.notify_to people, :creation, self
  end

  def set_default_attrs
    self.private = false if self.private.nil?
  end
end
