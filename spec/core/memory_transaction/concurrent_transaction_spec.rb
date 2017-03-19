require 'rspec'
require_relative '../../../src/stm'

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
        @balance = Balance.new(initial_amount)
      end

      def withdraw(amount)
        @balance.substract_amount(amount)
      end

      def balance
        @balance.current_amount
      end
    end

    class Balance
      def initialize(initial_amount)
        @amount = initial_amount
      end

      def substract_amount(amount)
        @amount = @amount - amount
      end

      def current_amount
        @amount
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

    expect(withdraw_and_get_balance.atomic).to eq(90)
  end

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
      end.to raise_exception /CommitConflict: (.*) was changed during current transaction./
    end

    run_new_thread_until_stopped do
      a_bank_account.withdraw(5)
      Thread.stop  # interrupt the thread
    end

    resume_thread(thread_a)
  end

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

  it 'assigment operation works well on Array, although the object was altered by another thread' do
    an_array = [1, 2, 3]

    thread_a = run_new_thread_until_stopped do
      puts 'Thread 1'
      Proc.new do
        an_array[0] = 7
        Thread.stop # interrupt the thread
      end.atomic

      if RUBY_ENGINE == 'rbx'
        # Check implementation internals
        expect(an_array.instance_variable_get(:@tuple)[0]).to eq(7)
        expect(an_array.instance_variable_get(:@tuple)[1]).not_to eq(8)
      end
      expect(an_array).to eq([7, 2, 3])
    end

    run_new_thread_until_stopped do
      puts 'Thread 2'
      Proc.new do
        an_array[1] = 8
        Thread.stop # interrupt the thread
      end.atomic # this thread will never commit
    end

    resume_thread(thread_a)
  end

  it 'an assigment operation on Array raises a commit conflic expection if the object was altered by another thread' do
    an_array = [1, 2, 3]

    thread_a = run_new_thread_until_stopped do
      puts 'Thread 1'
      expect do
        Proc.new do
          an_array[0] = 7
          Thread.stop # interrupt the thread
        end.atomic
      end.to raise_exception /CommitConflict: (.*) was changed during current transaction./
    end

    run_new_thread_until_stopped do
      puts 'Thread 2'
      an_array[1] = 8
      Thread.stop # interrupt the thread
    end

    resume_thread(thread_a)
  end

  it 'delete operation works well on Array, although the object was altered by another thread' do
    an_array = [1, 2, 3]

    thread_a = run_new_thread_until_stopped do
      puts 'Thread 1'
      Proc.new do
        an_array.delete_at(0)
        Thread.stop # interrupt the thread
      end.atomic

      if RUBY_ENGINE == 'rbx'
        # Check implementation internals
        expect(an_array.instance_variable_get(:@tuple)[0]).to eq(nil)
        expect(an_array.instance_variable_get(:@tuple)[1]).not_to eq(nil)
      end
      expect(an_array).to eq([2, 3])
    end

    run_new_thread_until_stopped do
      puts 'Thread 2'
      Proc.new do
        an_array.delete_at(1)
        Thread.stop # interrupt the thread
      end.atomic # this thread will never commit
    end

    resume_thread(thread_a)
  end

  it 'an delete operation on Array raises a commit conflic expection if the object was altered by another thread' do
    an_array = [1, 2, 3]

    thread_a = run_new_thread_until_stopped do
      puts 'Thread 1'
      expect do
        Proc.new do
          an_array.delete_at(0)
          Thread.stop # interrupt the thread
        end.atomic
      end.to raise_exception "CommitConflict: [1, 3] was changed during current transaction."
    end

    run_new_thread_until_stopped do
      puts 'Thread 2'
      an_array.delete_at(1)
      Thread.stop # interrupt the thread
    end

    resume_thread(thread_a)
  end

  # it 'string upcase works well, although the object was altered by another thread' do
  #   a_string = 'heLLo'
  #
  #   thread_a = run_new_thread_until_stopped do
  #     puts 'Thread 1'
  #     Proc.new do
  #       a_string.upcase!
  #       Thread.stop  # interrupt the thread
  #     end.atomic
  #
  #     expect(a_string).to eq('HELLO')
  #   end
  #
  #   run_new_thread_until_stopped do
  #     puts 'Thread 2'
  #     Proc.new do
  #       a_string.downcase!
  #       Thread.stop  # interrupt the thread
  #     end.atomic  # this thread will never commit
  #   end
  #
  #   resume_thread(thread_a)
  # end

  it 'an upcase operation on string raises a commit conflic expection if the object was altered by another thread' do
    a_string = 'heLLo'

    thread_a = run_new_thread_until_stopped do
      puts 'Thread 1'
      expect do
        Proc.new do
          a_string.upcase!
          Thread.stop # interrupt the thread
        end.atomic
      end.to raise_exception "CommitConflict: hello was changed during current transaction."
    end

    run_new_thread_until_stopped do
      puts 'Thread 2'
      a_string.downcase!
      Thread.stop # interrupt the thread
    end

    resume_thread(thread_a)
  end
end