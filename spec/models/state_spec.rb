require 'spec_helper'

describe State do
  it { should validate_presence_of :name }
  it { should validate_presence_of :machine_type }
  it { should validate_presence_of :role_id }
end
