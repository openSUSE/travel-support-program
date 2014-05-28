class CreateSourceStatesTransitions < ActiveRecord::Migration
  def change
    create_table(:source_states_transitions, id: false) do |t|
    	t.integer :state_id
    	t.integer :transition_event_id

    end
  end
end
