require_relative 'symbol'
require_relative 'unbound_method'
require_relative '../parsing/source_code_atomic_transformer'

class Module
  @@modules_with_atomic_methods = Set.new # We use a class variable, to be shared also with class Class instance

  def define_atomic_method(original_method_name)
    original_method = instance_method(original_method_name)
    if original_method.is_native? || original_method.is_a_kernel_alpha_method?
      define_method(original_method_name.to_atomic_method_name, original_method)
    else
      atomic_method_def = SourceCodeAtomicTransformer.new.transform_method_definition(original_method.definition)
      new_atomic_method_name = load_method_from_source(atomic_method_def)
      if original_method_name.to_atomic_method_name != new_atomic_method_name
        alias_method(original_method_name.to_atomic_method_name, new_atomic_method_name)
      end
    end
    self.class.register_module_with_an_atomic_method(self)

    original_method_name.to_atomic_method_name
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

  private

  def self.register_module_with_an_atomic_method(a_module)
    @@modules_with_atomic_methods.add(a_module)
  end

  def load_method_from_source(atomic_method_def)
    if RUBY_ENGINE == 'rbx'
      require_relative 'rbx/module'
      class_eval_with_kernel_code_support(atomic_method_def)
    else
      class_eval(atomic_method_def)
    end
  end
end