class Thread
  def self.set_current_transaction(a_transaction)
    Thread.current.thread_variable_set(:current_transaction, a_transaction)
  end

  def self.current_transaction
    return Thread.current.thread_variable_get(:current_transaction)
  end
end