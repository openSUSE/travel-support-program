class State < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  #The user creating this state
  belongs_to :user
  # The role of the user assigned to perform a transition from this state
  belongs_to_active_hash :role, :class_name => "UserRole", :shortcuts => [:name]
  #The unique transition_event whose target state is the given state
  has_one :target_event, :class_name => "TransitionEvent",:foreign_key => "target_state_id"
  
  #The associated transition_events whose source state is the given state 
  has_and_belongs_to_many :source_events, :class_name => "TransitionEvent", :join_table => "source_states_transitions"

  validates :name, :machine_type, :role_id, :presence => true

end
