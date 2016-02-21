class Binding
  if RUBY_ENGINE == 'rbx'
    def local_variable_defined?(method_name)
      local_variables.include?(method_name)
    end
  end
end