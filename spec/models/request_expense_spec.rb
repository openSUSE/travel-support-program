# frozen_string_literal: true

require 'spec_helper'

describe RequestExpense do
  fixtures :all

  it { is_expected.to validate_presence_of :request }

  # Decimals has been reported to fail with mysql
  # https://github.com/openSUSE/travel-support-program/issues/18
  context 'when storing decimal values' do
    let(:expense) { request_expenses(:luke_for_yavin_gas) }

    before do
      expense.estimated_amount = 100.53
      expense.approved_amount = 58.89
      expense.save
      expense.reload
    end

    it 'saves estimated amount' do
      expect(expense.estimated_amount).to eq 100.53
    end

    it 'saves approved amount' do
      expect(expense.approved_amount).to eq 58.89
    end
  end
end
