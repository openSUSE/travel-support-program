#
# Comment attached to a state machine
# Comments can be private (not visible by the requester) -in order to be used
# for discussing the final decision- or public -allowing two way communication
# with the requester-.
#
class Comment < ApplicationRecord
  # The associated state machine (request, reimbursement...)
  belongs_to :machine, polymorphic: true, inverse_of: :comments
  # The author of the note
  belongs_to :user

  validates :body, :user_id, :machine, presence: true
  validates_inclusion_of :private, in: [true, false]

  after_create :notify_creation
  after_initialize :set_default_attrs, if: :new_record?

  # The precision of 'created_at' is one second. For comments in the same second
  # we must use the id for fine-tuning
  scope :oldest_first, -> { order('created_at asc, id asc') }
  scope :newest_first, -> { order('created_at desc, id desc') }

  # Checks if the comment is public
  #
  # @return [Boolean] true is private is false (pretty obvious)
  def public?
    !private
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
    people = machine.class.roles_for_private_comments
    if private
      people += machine.comments.includes(:user).map(&:user).select { |u| u.profile.role_name == 'supervisor' }.uniq
    else
      people += [:requester] if machine.class.roles_for_public_comments.include?(:requester)
      people += machine.assigned_roles
      people += machine.comments.includes(:user).map(&:user).uniq
    end
    # Substitute :requester by the corresponding user
    people.map! { |p| p == :requester ? machine.user : p }
    CommentMailer.notify_to people.uniq, :creation, self
  end

  def set_default_attrs
    self.private = false if private.nil?
  end
end
