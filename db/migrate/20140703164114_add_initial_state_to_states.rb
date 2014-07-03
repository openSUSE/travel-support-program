class AddInitialStateToStates < ActiveRecord::Migration
  def change
  	add_column :states, :initial_state, :boolean
  end
end
