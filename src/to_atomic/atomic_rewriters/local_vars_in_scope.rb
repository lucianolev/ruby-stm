class LocalVarsInScope
  def initialize(binding)
    @source_binding = binding
  end

  def include?(var_name)
    begin
      return @source_binding.local_variable_defined?(var_name)
    rescue NameError # some method name are not valid local variable names so local_variable_defined? will raise a NameError
      false
    end
  end
end