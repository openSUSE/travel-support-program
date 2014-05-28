class TransitionEvent < ActiveRecord::Base
 

 attr_accessible :name, :machine_type, :user_id, :description

 #The user creating this transition_event
 belongs_to :user
 #The unique target state of the transition_event 
 belongs_to :target_state, :class_name => "State", :foreign_key => "target_state_id"

 #The associated states which are the source states for the given transition_event
 has_and_belongs_to_many :source_states, :class_name => "State", :join_table => "source_states_transitions"

 validates :name, :machine_type, :presence => true
 #Every tarnsition has only one unique target_state
 validates :target_state_id, :uniqueness => true

end
