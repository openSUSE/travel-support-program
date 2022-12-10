# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def ransackable_attributes(_)
      super & %w[end_date start_date name description event_id state]
    end

    def ransackable_associations(_)
      []
    end
  end
end
