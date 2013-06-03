require 'spec_helper'

describe ReimbursementAttachment do
  it { should validate_presence_of :reimbursement }
  it { should validate_presence_of :title }
  it { should validate_presence_of :file }
end
