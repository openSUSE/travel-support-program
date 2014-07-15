require 'spec_helper'

describe Expense do
  it { should validate_presence_of :request }
end
