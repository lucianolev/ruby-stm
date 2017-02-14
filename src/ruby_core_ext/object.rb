require_relative 'symbol'
require_relative 'module'
require_relative 'class'
require_relative '../core/memory_transaction'

require_relative 'internal_state_primitives/all'

class Object
  def method_missing(method_name, *args, &block)
    if method_name.is_an_atomic_method_name?
      define_and_dispatch_atomic_variant(method_name, args, block)
    else
      super
    end
  end

  def working_copy
    MemoryTransaction.current.change_for(self).working
  end

  define_method(:instance_variable_set.to_atomic_method_name) do |var_name, value|
    puts "DEBUG: Var #{var_name.inspect} set to value #{value.inspect} in working copy"
    working_copy.instance_variable_set(var_name, value)
  end

  define_method(:instance_variable_get.to_atomic_method_name) do |var_name|
    puts "DEBUG: Var #{var_name.inspect} get from working copy"
    working_copy.instance_variable_get(var_name)
  end

  private

  def define_and_dispatch_atomic_variant(method_name, args, block)
    original_method_name = method_name.to_nonatomic_method_name
    assert_original_method_is_defined(original_method_name)
    class_of_method = method(original_method_name).owner
    class_of_method.define_atomic_method(original_method_name)
    resend_atomic_method(method_name, args, block)
  end

  def assert_original_method_is_defined(original_method_name)
    unless respond_to?(original_method_name, true)
      raise "'#{self}' does not respond to original method '#{original_method_name}'!"
    end
  end

  def resend_atomic_method(method_name, args, block)
    if respond_to?(method_name, true)
      __send__(method_name, *args, &block)
    else
      raise "Fail to define atomic method '#{method(method_name.to_nonatomic_method_name).owner}##{method_name}'!"
    end
  end
end