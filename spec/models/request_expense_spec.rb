require 'spec_helper'

describe RequestExpense do
  fixtures :all

  it { should validate_presence_of :request }

  # Decimals has been reported to fail with mysql
  # https://github.com/openSUSE/travel-support-program/issues/18
  it 'stores and reads decimal values' do
    expense = request_expenses(:luke_for_yavin_gas)
    expense.estimated_amount = 100.53
    expense.approved_amount = 58.89
    expense.save

    expense.reload
    expect(expense.estimated_amount).to eq 100.53
    expect(expense.approved_amount).to eq 58.89
  end
end
