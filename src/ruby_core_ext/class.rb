class Class < Module
  def define_atomic_method(original_method_name)
    super
    define_atomic_method_for_subclasses(original_method_name)
    original_method_name.to_atomic_method_name
  end

  def subclasses_implementing_method(method_name)
    self.all_subclasses.select do |klass|
      klass.instance_methods(false).include?(method_name)
    end
  end

  def all_subclasses
    metaclass = self.singleton_class
    subclasses_including_self = ObjectSpace.each_object(metaclass)
    subclasses_including_self.reject { |klass| klass == self }
  end

  private

  def define_atomic_method_for_subclasses(orig_meth_name)
    subclasses_implementing_method(orig_meth_name).each do |klass|
      atomic_variant = orig_meth_name.to_atomic_method_name
      unless klass.instance_methods(false).include?(atomic_variant)
        klass.define_atomic_method(orig_meth_name)
      end
    end
  end
end