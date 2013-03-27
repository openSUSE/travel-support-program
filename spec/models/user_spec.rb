require 'spec_helper'
require 'cancan/matchers'

describe User do
  fixtures :users, :user_profiles, :events, :requests

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe "abilities" do
    subject { ability }
    let(:ability){ Ability.new(user) }
    let(:user){ nil }

    context 'when is a requester' do
      let(:user){ users(:luke) }

      it{ should be_able_to(:create, Request.new) }
      it{ should be_able_to(:read, requests(:luke_for_yavin)) }
      it{ should be_able_to(:update, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:read, requests(:wedge_for_yavin)) }
      it{ should_not be_able_to(:update, requests(:wedge_for_yavin)) }
    end
  end
end
