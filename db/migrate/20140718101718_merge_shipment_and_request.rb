# frozen_string_literal: true

class MergeShipmentAndRequest < ActiveRecord::Migration[4.2]
  class DummyRequest < ActiveRecord::Base
    self.inheritance_column = :foo
    self.table_name = 'requests'
  end
  class DummyShipment < ActiveRecord::Base
    self.table_name = 'shipments'
  end
  class DummyStateChange < ActiveRecord::Base
    self.table_name = 'state_changes'
  end
  class DummyComment < ActiveRecord::Base
    self.table_name = 'comments'
  end

  def up
    add_column :requests, :postal_address_id, :integer
    add_column :requests, :contact_phone_number, :string
    add_column :requests, :type, :string
    add_index :requests, :postal_address_id
    add_index :requests, :type

    DummyRequest.update_all type: 'TravelSponsorship'

    DummyShipment.all.each do |s|
      req = DummyRequest.create(type: 'Shipment',
                                state: s.state,
                                user_id: s.user_id,
                                event_id: s.event_id,
                                description: s.description,
                                created_at: s.created_at,
                                updated_at: s.updated_at,
                                state_updated_at: s.state_updated_at,
                                postal_address_id: s.postal_address_id,
                                contact_phone_number: s.contact_phone_number)
      changes = DummyStateChange.where(machine_type: 'Shipment', machine_id: s.id)
      changes.update_all(machine_id: req.id, machine_type: 'Request')
      comments = DummyComment.where(machine_type: 'Shipment', machine_id: s.id)
      comments.update_all(machine_id: req.id, machine_type: 'Request')
    end

    drop_table :shipments
  end

  def down
    create_table :shipments do |t|
      t.string      :state
      t.references  :user
      t.references  :event
      t.text        :description
      t.datetime    :state_updated_at
      t.string      :contact_phone_number
      t.integer     :postal_address_id

      t.timestamps
    end
    add_index :shipments, :postal_address_id

    DummyRequest.where(type: 'Shipment').each do |r|
      ship = DummyShipment.create(
        state: r.state,
        user_id: r.user_id,
        event_id: r.event_id,
        description: r.description,
        created_at: r.created_at,
        updated_at: r.updated_at,
        postal_address_id: r.postal_address_id,
        contact_phone_number: r.contact_phone_number
      )
      changes = DummyStateChange.where(machine_type: 'Request', machine_id: r.id)
      changes.update_all(machine_id: ship.id, machine_type: 'Shipment')
      comments = DummyComment.where(machine_type: 'Request', machine_id: r.id)
      comments.update_all(machine_id: ship.id, machine_type: 'Shipment')
    end
    DummyRequest.where(type: 'Shipment').delete_all

    remove_column :requests, :postal_address_id
    remove_column :requests, :contact_phone_number
    remove_column :requests, :type
  end
end
