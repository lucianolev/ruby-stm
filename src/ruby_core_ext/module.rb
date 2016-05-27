require_relative 'symbol'
require_relative 'unbound_method'

class Module
  @@modules_with_atomic_methods = Set.new # We use a class variable, to be shared also with class Class instance

  def self.remove_all_atomic_methods
    @@modules_with_atomic_methods.each do |a_module|
      a_module.remove_atomic_methods
      @@modules_with_atomic_methods.delete(a_module)
    end
  end

  def define_atomic_method(original_method_name)
    atomic_method = instance_method(original_method_name).to_atomic
    atomic_method.define_in(self)

    if original_method_name.to_atomic_method_name != atomic_method.name
      alias_method(original_method_name.to_atomic_method_name, atomic_method.name)
    end

    self.class.register_module_with_an_atomic_method(self)
    atomic_method.name
  end

  def remove_atomic_methods
    instance_methods(include_super=false)
        .find_all { |method| method.is_an_atomic_method_name? }
        .each { |method| remove_method(method) }
  end

  private

  def self.register_module_with_an_atomic_method(a_module)
    @@modules_with_atomic_methods.add(a_module)
  end

  def define_method_using_source_code(method_source_code)
    if RUBY_ENGINE == 'rbx'
      # Source code coming from RBX kernel should be loaded with kernel code support
      require_relative 'rbx/module'
      class_eval_with_kernel_code_support(method_source_code.to_s)
    else
      class_eval(method_source_code.to_s)
    end
  end
end