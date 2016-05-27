require_relative '../symbol'
require_relative '../module'
require_relative '../object'

class Object
  define_method(:instance_variable_set.to_atomic_method_name) do |var_name, value|
    #puts "Var #{var_name.inspect} set to value #{value.inspect}"
    working_copy.instance_variable_set(var_name, value)
  end

  define_method(:instance_variable_get.to_atomic_method_name) do |var_name|
    #puts "Var #{var_name.inspect} get"
    working_copy.instance_variable_get(var_name)
  end
end