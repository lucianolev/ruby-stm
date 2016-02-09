require_relative '../module'
require_relative '../object'

class Object
  define_method(atomic_name_of(:instance_variable_set)) do |var_name, value|
    #puts "Var #{var_name.inspect} set to value #{value.inspect}"
    working_copy.instance_variable_set(var_name, value)
  end

  define_method(atomic_name_of(:instance_variable_get)) do |var_name|
    #puts "Var #{var_name.inspect} get"
    working_copy.instance_variable_get(var_name)
  end
end