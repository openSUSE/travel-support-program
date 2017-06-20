require 'spec_helper'

describe Payment do
  it { should validate_presence_of :reimbursement }
  it { should validate_presence_of :date }
  it { should validate_presence_of :amount }
  it { should validate_presence_of :currency }
  it { should validate_presence_of :method }
end
