class Object

  # Similar to 'clone', but without calling initialize_copy for subclasses.
  def shallow_copy
    copy = start_new_copy

    Rubinius.invoke_primitive :object_copy_object, copy, self
    Rubinius.invoke_primitive :object_copy_singleton_class, copy, self

    copy.freeze if frozen?
    copy
  end

  protected

  # In Rubinius, instance variables implemented as C++ fields are hidden from developers.
  # Here we use the Mirror API to get those instance fields and merge them with visible
  # instance variables.
  def all_instance_variables
    reflection_api = Rubinius::Mirror.reflect(self)
    instance_variables = reflection_api.instance_variables
    all_instance_variables = Set.new(instance_variables)
    all_instance_variables.merge(reflection_api.instance_fields)

    if self.kind_of?(Module)
      all_instance_variables.subtract([:@method_table,
                                       :@module_name,
                                       :@constant_table,
                                       :@origin])
    end

    all_instance_variables
  end

  private

  def start_new_copy
    Rubinius::Type.object_class(self).allocate
  end
end