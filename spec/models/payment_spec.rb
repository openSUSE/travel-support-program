# frozen_string_literal: true

require 'spec_helper'

describe Payment do
  it { is_expected.to validate_presence_of :reimbursement }
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :amount }
  it { is_expected.to validate_presence_of :currency }
  it { is_expected.to validate_presence_of :method }
end
