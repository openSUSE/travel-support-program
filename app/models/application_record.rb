# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def ransackable_attributes(_auth_object)
      super & %w[id end_date start_date name description event_id state]
    end

    def ransackable_associations(_auth_object)
      []
    end
  end
end
