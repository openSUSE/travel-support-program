class AddAllowedRolesToTransitionEvents < ActiveRecord::Migration
  def change
  	add_column :transition_events, :allowed_roles, :text
  end
end
