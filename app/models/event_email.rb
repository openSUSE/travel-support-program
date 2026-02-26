# frozen_string_literal: true

class EventEmail < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :to, presence: true
  validates :subject, presence: true, length: { maximum: 200 }
  validates :body, presence: true, length: { maximum: 5000 }
end
