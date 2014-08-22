module HasComments

  extend ActiveSupport::Concern

  included do
    # Comments used to discuss decisions (private) or communicate
    # with the requester (public)
    has_many :comments, :as => :machine, :dependent => :destroy
  end

  #
  # Class methods
  #
  module ClassMethods

    # Macro-style method to define which roles are allowed to access to public
    # comments.
    #
    # @param [Object] roles  can be the name of a role or an array of names
    def allow_public_comments_to(roles)
      roles = [roles].flatten.map(&:to_sym)
      @roles_for_public_comments ||= []
      @roles_for_public_comments += roles
    end

    # Macro-style method to define which roles are allowed to access to all the
    # comments (public and private)
    #
    # @param [Object] roles  can be the name of a role or an array of names
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
      @roles_for_public_comments || []
    end

    # Names of the roles allowed to access private comments
    #
    # @see #allow_all_comments_to
    #
    # @return [Array] array of symbols
    def roles_for_private_comments
      @roles_for_private_comments || []
    end

    # Checks if a given role has been granted access to public comments
    #
    # @param [#to_sym] role name of the role
    # @return [Boolean] true if the user is authorized
    def allow_public_comments?(role)
      roles_for_public_comments.include? role.to_sym
    end

    # Checks if a given role has been granted access to private comments
    #
    # @param [#to_sym] role name of the role
    # @return [Boolean] true if the user is authorized
    def allow_private_comments?(role)
      roles_for_private_comments.include? role.to_sym
    end

    # Hint about the private field
    #
    # @return [String] a text explaining the meaning of the private field
    def private_comment_hint
      I18n.t(:comment_private_hint, roles: roles_for_private_comments.to_sentence)
    end
  end
end
