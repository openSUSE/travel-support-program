# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def ransackable_attributes(_auth_object = nil)
      column_names & %w[id end_date start_date name description event_id state state_updated_at country_code shipment_type amount currency]
    end

    def ransackable_associations(_auth_object = nil)
      []
    end
  end
end
