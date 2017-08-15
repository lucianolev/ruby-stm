require 'rspec'
require_relative '../../src/stm'
require_relative 'concurrently'
require_relative 'real_bank_account'

describe 'Testing BankAccount operations' do
  def expect_balance(account_sym, expected_balance)
    balance_msg = Proc.new do |account_sym, expected|
      "El balance de #{account_sym} es #{instance_variable_get(account_sym).balance}, en lugar de #{expected}"
    end
    expect(instance_variable_get(account_sym).balance).to eq(expected_balance), balance_msg.call(account_sym,
                                                                                                 expected_balance)
  end

  before do
    if RUBY_ENGINE == 'rbx'
      skip 'Rubinius VM crashes when executing this real life example.'
    end

    @an_account = RealBankAccount.new(40)
    @another_account = RealBankAccount.new(10)
  end

  it 'should withdraw from an account multiple times correctly' do
    concurrently(20) do
      Proc.new do
        @an_account.withdraw(2)
      end.atomic_retry
    end

    expect_balance(:@an_account, 0)
  end

  it 'should transfer from an account to another correctly', :aggregate_failures do
    concurrently(20) do
      Proc.new do
        @an_account.transfer_to(2, @another_account)
      end.atomic_retry
    end

    expect_balance(:@an_account, 0)
    expect_balance(:@another_account, 50)
  end

  it 'should transfer an account to another one AND BACK TO THE ORIGINAL correctly', :aggregate_failures do
    concurrently(20) do
      Proc.new do
        @an_account.transfer_to(2, @another_account)
        @another_account.transfer_to(2, @an_account)
      end.atomic_retry
    end

    expect_balance(:@an_account, 40)
    expect_balance(:@another_account, 10)
  end
end