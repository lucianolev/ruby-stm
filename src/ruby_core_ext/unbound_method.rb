if RUBY_ENGINE == 'rbx'
  require_relative 'rbx/unbound_method'
end
require_relative '../source_code/unbound_method_source_code'
require_relative '../to_atomic/atomic_unbound_method'

class UnboundMethod
  def source_code
    UnboundMethodSourceCode.new(self)
  end

  def to_atomic
    AtomicUnboundMethod.from(self)
  end
end