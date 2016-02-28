require_relative 'symbol'
require_relative 'unbound_method'
require_relative '../parsing/source_code_atomic_transformer'

class Module
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
      original_method_name.to_atomic_method_name
    end
  end

  private

  def load_method_from_source(atomic_method_def)
    if RUBY_ENGINE == 'rbx'
      require_relative 'rbx/module'
      class_eval_with_kernel_code_support(atomic_method_def)
    else
      class_eval(atomic_method_def)
    end
  end
end