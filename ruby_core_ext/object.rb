require_relative 'module'

class Object
  def method_missing(method_name, *args)
    if self.class.method_is_atomic?(method_name)
      original_method_name = self.class.atomic_method_nonatomic_name(method_name)
      atomic_method_name = self.class.define_atomic_method(original_method_name)
      send(atomic_method_name, *args)
    else
      super
    end
  end

  def atomic_instance_variable_set(var_name, value)
    #puts "Var #{var_name.inspect} set to value #{value.inspect}"
    working_copy.instance_variable_set(var_name, value)
  end

  def atomic_instance_variable_get(var_name)
    #puts "Var #{var_name.inspect} get"
    working_copy.instance_variable_get(var_name)
  end

  def working_copy
    transaction = $current_transaction
    transaction.change_for(self).working
  end

  def has_same_internal_state(an_object)
    same_number_of_inst_vars = self.instance_variables.size == an_object.instance_variables.size
    if same_number_of_inst_vars
      self.instance_variables.each do |inst_var_name|
        if self.instance_variable_get(inst_var_name) != an_object.instance_variable_get(inst_var_name)
          false
        end
      end
    end
    true
  end

  def copy_internal_state(an_object)
    # clone = self.class.allocate
    # clone.copy_instance_variables(an_object)
  end
end