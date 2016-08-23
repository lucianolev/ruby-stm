class Hash
  def has_same_internal_state?(an_obj)
    self == an_obj
  end

  def copy_internal_state(an_object)
    self.replace(an_object)
  end

  # HACK: According to Rubinius devs, 'instance_variables'
  #   implementation does not return instance variables for
  #   primitive types to protect Ruby devs breaking the data
  #   structure. However, instance_variable_get and
  #   instance_variable_set works, so the code can be transformed.
  #   Here we return the instance variables manually (extracted
  #   from manual code inspection) to solve the problem.
  #
  #   TODO: Check why this isn't working for Hash class.
  #
  # def instance_variables
  #   [:@entries, :@state, :@default, :@default_proc, :@size, :@capacity, :@mask, :@max_entries, ]
  # end
  #
  # class State
  #   def instance_variables
  #     [:@compare_by_identity, :@head, :@tail]
  #   end
  # end
  #
  # class Bucket
  #   def instance_variables
  #     [:@key, :@key_hash, :@value, :@link, :@state, :@previous, :@next]
  #   end
  # end
end