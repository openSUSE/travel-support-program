# frozen_string_literal: true

require 'spec_helper'

describe Comment do
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :body }
  it { should validate_presence_of :machine }
end
