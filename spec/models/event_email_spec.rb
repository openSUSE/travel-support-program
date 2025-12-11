# frozen_string_literal: true

require 'spec_helper'

describe EventEmail do
  fixtures :all

  it { is_expected.to validate_presence_of :to }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_length_of(:subject).is_at_most(200) }
  it { is_expected.to validate_presence_of :body }
  it { is_expected.to validate_length_of(:body).is_at_most(5000) }
end
