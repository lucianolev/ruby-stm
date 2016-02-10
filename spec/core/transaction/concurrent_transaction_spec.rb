require 'rspec'
require_relative '../../../ruby_core_ext/proc'

describe 'Concurrent transactions' do
  def run_new_thread_until_stopped(&block)
    thread = Thread.new(&block)
    sleep(0.1) while thread.status != 'sleep'
    thread
  end

  def resume_thread(thread)
    thread.run.join
  end

  before do
    class BankAccount
      def initialize(initial_amount)
        @balance = initial_amount
      end

      def withdraw(amount)
        @balance = @balance - amount
      end

      def balance
        @balance
      end
    end
  end

  it 'an atomic withdraw yields a correct balance' do
    a_bank_account = BankAccount.new(100)

    withdraw_and_get_balance = Proc.new do
      a_bank_account.withdraw(3)
      a_bank_account.withdraw(7)
      a_bank_account.balance
    end

    expect(withdraw_and_get_balance.call).to eq(90)
  end

  # TODO: does it make sense to test this?
  it 'an atomic withdraw yields a correct balance, although the object was altered by another thread' do
    a_bank_account = BankAccount.new(100)

    thread_a = run_new_thread_until_stopped do
      Proc.new do
        a_bank_account.withdraw(3)
        Thread.stop  # interrupt the thread
      end.atomic

      expect(a_bank_account.balance).not_to eq(92)
      expect(a_bank_account.balance).to eq(97)
    end

    run_new_thread_until_stopped do
      Proc.new do
        a_bank_account.withdraw(5)
        Thread.stop  # interrupt the thread
      end.atomic  # this thread will never commit
    end

    resume_thread(thread_a)
  end

  it 'an atomic withdraw raises a commit conflic expection if the object was altered by another thread' do
    a_bank_account = BankAccount.new(100)

    thread_a = run_new_thread_until_stopped do
      expect do
        Proc.new do
          a_bank_account.withdraw(3)
          Thread.stop  # interrupt the thread
        end.atomic
      end.to raise_exception 'CommitConflict'
    end

    run_new_thread_until_stopped do
      a_bank_account.withdraw(5)
      Thread.stop  # interrupt the thread
    end

    resume_thread(thread_a)
  end

  # TODO: does it make sense to test this?
  it 'an atomic withdraw yields a correct balance, although the object was altered by another fiber' do
    a_bank_account = BankAccount.new(100)

    fiber_a = Fiber.new do
      Proc.new do
        a_bank_account.withdraw(3)
        Fiber.yield  # stop the fiber before commiting
      end.atomic

      expect(a_bank_account.balance).not_to eq(92)
      expect(a_bank_account.balance).to eq(97)
    end

    fiber_a.resume  # start and run until yield

    Fiber.new do
      Proc.new do
        a_bank_account.withdraw(5)
        Fiber.yield  # stop the fiber before commiting
      end.atomic
    end.resume  # start and run until yield

    fiber_a.resume  # continue
  end
end