# frozen_string_literal: true

require 'spec_helper'

describe ReimbursementAttachment do
  it { is_expected.to validate_presence_of :reimbursement }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :file }
end
