class TransitionEvent < ActiveRecord::Base
 

 attr_accessible :name, :machine_type, :user_id, :description, :source_state_ids, :target_state_id

 #The user creating this transition_event
 belongs_to :user
 #The unique target state of the transition_event 
 belongs_to :target_state, :class_name => "State", :foreign_key => "target_state_id"

 #The associated states which are the source states for the given transition_event
 has_and_belongs_to_many :source_states, :class_name => "State", :join_table => "source_states_transitions"

 validates :name, :machine_type, :presence => true
 #Every tarnsition has only one unique target_state
 validates :target_state_id, :uniqueness => true


#Method to validate(i.e. belong to same machine) the transition occuring between the states by checking
#for number of unique values in an array of all associated machine_types
 def valid_transition?
 	(source_states.map(&:machine_type) + [target_state.machine_type] + [machine_type]).uniq.size == 1
 end

end
