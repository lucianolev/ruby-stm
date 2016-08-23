class Class < Module
  def define_atomic_method(original_method_name)
    super
    define_atomic_method_for_subclasses(original_method_name)
    original_method_name.to_atomic_method_name
  end

  def subclasses_implementing_method(method_name)
    ObjectSpace.each_object(singleton_class).select do |klass|
      klass != self and
          klass.instance_methods(false).include?(method_name)
    end
  end

  private

  def define_atomic_method_for_subclasses(orig_meth_name)
    subclasses_implementing_method(orig_meth_name).each do |klass|
      klass.define_atomic_method(orig_meth_name)
    end
  end
end