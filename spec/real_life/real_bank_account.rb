# BankAccount
class RealBankAccount
  def initialize(initial_amount)
    @balance = initial_amount
  end

  attr_reader :balance

  def deposit(amount)
    new_balance = @balance + amount
    sleep(0.0000001) # thread switch!
    @balance = new_balance
  end

  def withdraw(amount)
    new_balance = @balance - amount
    sleep(0.0000001) # thread switch!
    @balance = new_balance
  end

  def transfer_to(amount, another_account)
    withdraw(amount)
    another_account.deposit(amount)
  end
end