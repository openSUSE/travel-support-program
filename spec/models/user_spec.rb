# frozen_string_literal: true

require 'spec_helper'

describe User do
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :password }
end
