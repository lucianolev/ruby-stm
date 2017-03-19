class Object
  def has_same_object_state?(an_obj)
    all_instance_variables.all? do |ivar_name|
      ivar_self = self.instance_variable_get(ivar_name)
      ivar_an_obj = an_obj.instance_variable_get(ivar_name)
      ivar_self.equal?(ivar_an_obj)
    end
  end

  private

  def copy_object_state(an_obj)
    Rubinius.invoke_primitive :object_copy_object, self, an_obj
  end

  def copy_singleton_class(an_obj)
    Rubinius.invoke_primitive :object_copy_singleton_class, self, an_obj
  end

  # In Rubinius, instance variables implemented as C++ fields are hidden from developers.
  # Here we use the Mirror API to get those instance fields and merge them with visible
  # instance variables.
  def all_instance_variables
    reflection_api = Rubinius::Mirror.reflect(self)
    instance_variables = reflection_api.instance_variables
    all_instance_variables = Set.new(instance_variables)
    all_instance_variables.merge(reflection_api.instance_fields)
  end
end