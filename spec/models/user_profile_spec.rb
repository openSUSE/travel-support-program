# frozen_string_literal: true

require 'spec_helper'

describe UserProfile do
  it { should validate_presence_of :role_id }
end
