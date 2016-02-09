require_relative '../ruby_core_ext/thread'
require_relative 'module'

class Object
  def method_missing(method_name, *args)
    if self.class.method_is_atomic?(method_name)
      original_method_name = self.class.atomic_method_nonatomic_name(method_name)

      # Class methods should be defined in singleton's
      # class of the object, instead of in Class class.
      if self.is_a?(Class)
        object_class = self.singleton_class
      else
        object_class = self.class
      end
      object_class.define_atomic_method(original_method_name)

      __send__(method_name, *args)  # resend the message
    else
      super
    end
  end

  def working_copy
    transaction = Thread.current_transaction
    if transaction.nil?
      raise 'No current transaction!'
    end
    transaction.change_for(self).working
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
    end
    true
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
end