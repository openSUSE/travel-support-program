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


#Method to validate(i.e. belong to same machine) the transition occuring between the states
 def valid_transition?
 	self.source_states.each do |source_state|
 		if(source_state.machine_type != self.target_state.machine_type)  #source-target conflict
 			return false
 		elsif(source_state.machine_type != self.machine_type)            #source-event conflict
 			return false
 		elsif (target_state.machine_type != self.machine_type)			 #target-event conflict
 			return false	
 		end
 	end
 	return true
 end

end
