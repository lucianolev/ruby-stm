class Binding

  # local_variable_defined? is not defined in rbx (at least on versions < 3.14)
  def local_variable_defined?(method_name)
    local_variables.include?(method_name)
  end

end