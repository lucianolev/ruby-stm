require 'pathname'
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
    AtomicUnboundMethod.of(self)
  end

  def source_code_available?
    !is_native?
  end

  def is_native?
    source_location.nil?
  end

  def define_in(a_module)
    a_module.send(:define_method, self.name, self)
  end
end