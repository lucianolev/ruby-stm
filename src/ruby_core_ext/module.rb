require_relative 'symbol'
require_relative 'unbound_method'

require_relative 'module_extensions/all'

class Module
  @@modules_with_atomic_methods = Set.new # We use a class variable, to be shared also with class Class instance

  def self.register_module_with_an_atomic_method(a_module)
    @@modules_with_atomic_methods.add(a_module)
  end

  def self.remove_all_atomic_methods
    @@modules_with_atomic_methods.each do |a_module|
      a_module.remove_atomic_methods
      @@modules_with_atomic_methods.delete(a_module)
    end
  end

  def remove_atomic_methods
    instance_methods(include_super=false)
        .find_all { |method| method.is_an_atomic_method_name? }
        .each { |method| remove_method(method) }
  end

  def aliased_methods(method)
    instance_methods(false).collect do |other_meth_name|
      instance_method(other_meth_name) == method &&
          other_meth_name != method.name
    end
  end

  private

  def define_method_using_source_code(name, meth_source_code)
    if name != meth_source_code.name_in_definition
      meth_source_code.change_name_in_definition!(name)
    end
    if RUBY_ENGINE == 'rbx'
      # Source code coming from RBX kernel should be loaded with kernel code support
      require_relative 'rbx/module'
      class_eval_with_kernel_code_support(meth_source_code.to_s)
    else
      class_eval(meth_source_code.to_s)
    end
  end
end