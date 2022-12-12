# frozen_string_literal: true

require 'spec_helper'

describe EventEmail do
  fixtures :all

  it { should validate_presence_of :to }
  it { should validate_presence_of :subject }
  it { should validate_length_of(:subject).is_at_most(200) }
  it { should validate_presence_of :body }
  it { should validate_length_of(:body).is_at_most(5000) }
end
