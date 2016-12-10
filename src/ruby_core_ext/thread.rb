class Thread
  def self.register_current_transaction(a_transaction)
    # By using []/[]= instead of thread_variable_set/get, transactions are Fiber-local instead of Thread-local.
    # This made possible to use atomic when working with Fibers.
    #Thread.current.thread_variable_set(:current_transaction, a_transaction)
    raise 'A transaction has already been registered for the current thread!' if is_there_a_current_transaction_registered?
    Thread.current[:current_transaction] = a_transaction
  end

  def self.current_transaction
    # By using []/[]= instead of thread_variable_set/get, transactions are Fiber-local instead of Thread-local.
    # This made possible to use atomic when working with Fibers.
    #return Thread.current.thread_variable_get(:current_transaction)
    raise 'No transaction registered!' unless is_there_a_current_transaction_registered?
    return Thread.current[:current_transaction]
  end

  def self.is_there_a_current_transaction_registered?
    return !Thread.current[:current_transaction].nil?
  end

  def self.unregister_current_transaction
    raise 'No transaction registered!' unless is_there_a_current_transaction_registered?
    Thread.current[:current_transaction] = nil
  end
end