require 'pathname'
if RUBY_ENGINE == 'rbx'
  require_relative 'rbx/unbound_method'
end
require_relative '../source_code/unbound_method_source_code'
require_relative '../to_atomic/atomic_unbound_method'

class UnboundMethod
  def source_code
    unless source_code_available?
      raise 'Source code is not available for this UnboundMethod.'
    end
    UnboundMethodSourceCode.new(self)
  end

  def to_atomic
    AtomicUnboundMethod.of(self)
  end

  def source_code_available?
    !is_native? && !is_a_primitive_kernel_method?
  end

  def is_native?
    source_location.nil?
  end

  def is_a_primitive_kernel_method?
    if RUBY_ENGINE == 'rbx'
      unless source_location.nil?
        return source_location[0] ==
            File.join(RbConfig::CONFIG['prefix'], 'core/alpha.rb')
      end
    end
    false
  end

  def define_in(a_module, name)
    a_module.send(:__original__define_method, name, self)
  end
end