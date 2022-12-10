# frozen_string_literal: true

require 'spec_helper'

describe ReimbursementLink do
  it { should validate_presence_of :reimbursement }
  it { should validate_presence_of :title }
  it { should validate_presence_of :url }
end
