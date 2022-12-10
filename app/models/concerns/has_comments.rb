# frozen_string_literal: true

#
# Concern adding a 'comments' association and some macro-style methods to define
# the permissions on public and private comments
#
module HasComments
  extend ActiveSupport::Concern

  included do
    # Comments used to discuss decisions (private) or communicate
    # with the requester (public)
    has_many :comments, as: :machine, dependent: :destroy
  end

  #
  # Class methods
  #
  module ClassMethods
    # Macro-style method to define which roles are allowed to access to public
    # comments.
    #
    # @param [Object] roles  can be the name of a role (or the special value
    #       :requester) or an array of names (also supporting :requester)
    def allow_public_comments_to(roles)
      roles = [roles].flatten.map(&:to_sym)
      @roles_for_public_comments ||= []
      @roles_for_public_comments += roles
    end

    # Macro-style method to define which roles are allowed to access to all the
    # comments (public and private)
    #
    # @param [Object] roles  can be the name of a role (or the special value
    #       :requester) or an array of names (also supporting :requester)
    def allow_all_comments_to(roles)
      roles = [roles].flatten.map(&:to_sym)
      @roles_for_public_comments ||= []
      @roles_for_private_comments ||= []
      @roles_for_public_comments += roles
      @roles_for_private_comments += roles
    end

    # Names of the roles allowed to access public comments
    #
    # @see #allow_public_comments_to
    # @see #allow_all_comments_to
    #
    # @return [Array] array of symbols
    def roles_for_public_comments
      @roles_for_public_comments.dup || []
    end

    # Names of the roles allowed to access private comments
    #
    # @see #allow_all_comments_to
    #
    # @return [Array] array of symbols
    def roles_for_private_comments
      @roles_for_private_comments.dup || []
    end

    # Checks if a given role has been granted access to public comments
    #
    # @param [#to_sym] role name of the role
    # @return [Boolean] true if the user is authorized
    def allow_public_comments?(role)
      # :requester is not longer a role, but a special value
      if role.to_sym == :requester
        false
      else
        roles_for_public_comments.include? role.to_sym
      end
    end

    # Checks if a given role has been granted access to private comments
    #
    # @param [#to_sym] role name of the role
    # @return [Boolean] true if the user is authorized
    def allow_private_comments?(role)
      # :requester is not longer a role, but a special value
      if role.to_sym == :requester
        false
      else
        roles_for_private_comments.include? role.to_sym
      end
    end

    # Checks if the requester has been granted access to private comments
    #
    # @return [Boolean] true if the user is authorized
    def private_comments_for_requester?
      roles_for_private_comments.include? :requester
    end

    # Checks if the requester has been granted access to public comments
    #
    # @return [Boolean] true if the user is authorized
    def public_comments_for_requester?
      roles_for_public_comments.include? :requester
    end

    # Hint about the private field
    #
    # @return [String] a text explaining the meaning of the private field
    def private_comment_hint
      roles = roles_for_private_comments
      if roles.include?(:requester)
        I18n.t(:comment_private_hint_requester, roles: (roles - [:requester]).to_sentence)
      else
        I18n.t(:comment_private_hint, roles: roles.to_sentence)
      end
    end
  end
end
