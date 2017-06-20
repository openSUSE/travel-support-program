class CreateReimbursements < ActiveRecord::Migration
  def change
    create_table :reimbursements do |t|
      t.string   'state'
      t.integer  'user_id', null: false
      t.integer  'request_id', null: false
      t.text     'description'
      t.text     'requester_notes'
      t.text     'tsp_notes'
      t.text     'administrative_notes'
      t.datetime 'incomplete_since'
      t.datetime 'tsp_pending_since'
      t.datetime 'tsp_approved_since'
      t.datetime 'payment_pending_since'
      t.datetime 'payed_since'
      t.datetime 'completed_since'
      t.datetime 'canceled_since'

      t.timestamps
    end
  end
end
