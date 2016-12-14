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

  # def instance_variables
  #   [:@default, :@default_proc, :@trie, :@state]
  # end
  #
  # class State
  #   def instance_variables
  #     [:@size, :@head, :@tail, :@compare_by_identity]
  #   end
  # end
  #
  # class Item
  #   def instance_variables
  #     [:@key, :@key_hash, :@value, :@previous]
  #   end
  # end
  #
  # class List
  #   def instance_variables
  #     [:@key_hash, :@entries]
  #   end
  # end
  #
  # class Trie
  #   def instance_variables
  #     [:@level, :@bmp, :@entries]
  #   end
  # end
  #
  # class Iterator
  #   def instance_variables
  #     [:@state]
  #   end
  # end
end