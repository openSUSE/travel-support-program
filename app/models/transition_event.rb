class TransitionEvent < ActiveRecord::Base

  #The user creating this transition_event
  belongs_to :user
  #The unique target state of the transition_event 
  belongs_to :target_state, :class_name => "State", :foreign_key => "target_state_id"

  #The associated states which are the source states for the given transition_event
  has_and_belongs_to_many :source_states, :class_name => "State", :join_table => "source_states_transitions"

  validates :name, :machine_type, :presence => true
  #Every tarnsition has only one unique target_state
  validates :target_state_id, :uniqueness => true

  validate :validates_machine_type


  #Checks whether the transition event is valid
  #
  #valid if source_states and target_state are of same machine_type as transition_event
  def validates_machine_type
    if (source_states.map(&:machine_type) + [target_state.machine_type] + [machine_type]).uniq.size != 1
 	    errors.add(:name, :invalid_transition_event)
    end
  end

end
