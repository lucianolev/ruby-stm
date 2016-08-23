class Array

  # HACK: According to Rubinius devs, 'instance_variables'
  #   implementation does not return instance variables for
  #   primitive types to protect Ruby devs breaking the data
  #   structure. However, instance_variable_get and
  #   instance_variable_set works, so the code can be transformed.
  #   Here we return the instance variables manually (extracted
  #   from manual code inspection) to solve the problem.
  def instance_variables
    [:@total, :@tuple, :@start]
  end
end