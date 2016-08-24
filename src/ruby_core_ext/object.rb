require_relative 'symbol'
require_relative 'module'
require_relative 'class'
require_relative '../core/memory_transaction'

if RUBY_ENGINE == 'rbx'
  Dir[File.join(__dir__, 'primitives_internal_state/rbx', '*.rb')].each { |file| require_relative file }
end
if RUBY_ENGINE == 'ruby'
  Dir[File.join(__dir__, 'primitives_internal_state/mri', '*.rb')].each { |file| require_relative file }
end

class Object
  def method_missing(method_name, *args, &block)
    if method_name.is_an_atomic_method_name?
      original_method_name = method_name.to_nonatomic_method_name
      assert_original_method_is_defined(original_method_name)
      class_of_method = class_of_method_def(original_method_name)
      class_of_method.define_atomic_method(original_method_name)
      resend_atomic_method(method_name, args, block)
    else
      super
    end
  end

  def working_copy
    MemoryTransaction.current.change_for(self).working
  end

  def has_same_internal_state?(an_obj)
    self.instance_variables.each do |ivar_name|
      if self.instance_variable_get(ivar_name) !=
          an_obj.instance_variable_get(ivar_name)
        return false
      end
    end
    true
  end

  def copy_internal_state(an_object)
    an_object.instance_variables.each do |inst_var_name|
      self.instance_variable_set(inst_var_name,
                                 an_object.instance_variable_get(inst_var_name))
    end
  end

  define_method(:instance_variable_set.to_atomic_method_name) do |var_name, value|
    # puts "Var #{var_name.inspect} set to value #{value.inspect}"
    working_copy.instance_variable_set(var_name, value)
  end

  define_method(:instance_variable_get.to_atomic_method_name) do |var_name|
    # puts "Var #{var_name.inspect} get"
    working_copy.instance_variable_get(var_name)
  end

  private

  def class_of_method_def(method_name)
    # Singleton methods are defined in singleton's class of the object instead of object's class.
    if self.singleton_methods.include?(method_name)
      self.singleton_class
    else
      self.class
    end
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
      raise "Fail to define atomic method '#{class_of_method_def(method_name.to_nonatomic_method_name)}##{method_name}'!"
    end
  end
end