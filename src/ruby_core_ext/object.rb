require_relative 'symbol'
require_relative 'module'
require_relative 'class'
require_relative '../core/memory_transaction'

class Object
  def method_missing(method_name, *args, &block)
    if method_name.is_an_atomic_method_name?
      original_method_name = method_name.to_nonatomic_method_name
      assert_original_method_is_defined(original_method_name)
      class_of_method_def(original_method_name).define_atomic_method(original_method_name)
      resend_atomic_method(method_name, args, block)
    else
      super
    end
  end

  def working_copy
    MemoryTransaction.current.change_for(self).working
  end

  def has_same_internal_state?(an_object)
    if self.is_a_morphable_primitive?
      return self == an_object
    end

    same_number_of_inst_vars = self.instance_variables.size == an_object.instance_variables.size
    if same_number_of_inst_vars
      self.instance_variables.each do |inst_var_name|
        if self.instance_variable_get(inst_var_name) != an_object.instance_variable_get(inst_var_name)
          return false
        end
      end
      true
    else
      false
    end
  end

  def copy_internal_state(an_object)
    if self.is_a_morphable_primitive?
      self.replace(an_object)
      return
    end

    an_object.instance_variables.each do |inst_var_name|
      self.instance_variable_set(inst_var_name, an_object.instance_variable_get(inst_var_name))
    end
  end

  def is_a_morphable_primitive?
    self.is_a?(Array) or self.is_a?(String) or self.is_a?(Hash)
  end

  private

  def class_of_method_def(original_method_name)
    # Class/Module methods and singleton methods should be defined in singleton's
    # class of the object, instead of in Class class or the object class in the case of singleton methods.
    if self.is_a?(Module) || self.singleton_methods.include?(original_method_name)
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