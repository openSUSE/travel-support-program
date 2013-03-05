class AddNotesToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :requester_notes, :text
    add_column :requests, :tsp_notes, :text
  end
end
