class Object
  def copy_object_from(an_obj)
    copy_object_state(an_obj)
    copy_singleton_class(an_obj)
  end

  def has_same_object_state?(an_obj)
    instance_variables.all? do |ivar_name|
      ivar_self = self.instance_variable_get(ivar_name)
      ivar_an_obj = an_obj.instance_variable_get(ivar_name)
      ivar_self.equal?(ivar_an_obj)
    end
  end

  def shallow_copy
    copy = start_new_copy
    copy.copy_object_from(self)

    copy.freeze if frozen?
    copy
  end

  private

  def start_new_copy
    self.class.allocate
  end

  def copy_object_state(an_obj)
    an_obj.instance_variables.each do |ivar_name|
      self.instance_variable_set(ivar_name,
                                 an_obj.instance_variable_get(ivar_name))
    end
  end

  def copy_singleton_class(an_obj)
    # FIXME: Should implement in VM

    # As 'self' is from a different hierchachy than 'an_obj',
    # the following solution raises exception:
    # 'TypeError: can't bind singleton method to a different class'.
    # This must be implemented as a VM primitive

    # an_obj.singleton_class.instance_methods(false).each do |meth_name|
    #   method = an_obj.singleton_class.instance_method(meth_name)
    #   self.singleton_class.send(:define_method, meth_name, method)
    # end

    # FIXME
    # Singleton methods that mutate singleton class state will
    # modify original singleton class instead of the copy!
    an_obj.singleton_methods(false).each do |meth_name|
      method = an_obj.singleton_method(meth_name)
      self.define_singleton_method(meth_name, &method)
    end
  end

  # def has_the_same_singleton_class?(an_obj)
  #   # FIXME: Should implement in VM
  #   # As copying the singleton class is not currently implemented,
  #   # self and an_obj will have different singleton clases, so
  #   # comparing both will fail
  #   # Notice that we don't compare by internal state here because
  #   # although we'll be copying the class, the internal reference
  #   # would...
  #   # self.singleton_class == an_obj.singleton_class
  #
  #   # Alt 1:
  #   # self.singleton_class.has_same_internal_state?(an_obj.singleton_class)
  #
  #   # Alt 2:
  #   # methods_excluding_atomic = Proc.new do |klass|
  #   #   instance_methods_names = klass.instance_methods(false)
  #   #   instance_methods_names
  #   #       .reject { |meth| meth.is_an_atomic_method_name? }
  #   # end
  #   # self_singleton_meths = methods_excluding_atomic.call(self.singleton_class)
  #   # an_obj_singleton_meths = methods_excluding_atomic.call(an_obj.singleton_class)
  #   # self_singleton_meths.sort == an_obj_singleton_meths.sort
  #
  #   # Alt 3:
  #   # instance_methods_names = self.singleton_class.instance_methods(false)
  #   # instance_methods = instance_methods_names.collect do |meth_name|
  #   #   unless meth_name.is_an_atomic_method_name?
  #   #     self.singleton_class.instance_method(meth_name)
  #   #   end
  #   # end
  #   # instance_methods.all? do |meth_name|
  #   #   has_method = an_obj.singleton_class.instance_methods(false).include? meth_name
  #   #   same_method = an_obj.singleton_class.instance_method(meth_name) == self.singleton_class.instance_method(meth_name)
  #   #   has_method && same_method
  #   # end
  # end
end