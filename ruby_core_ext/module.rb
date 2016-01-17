require_relative 'unbound_method'
require_relative '../parsing/source_code_reader'
require_relative '../parsing/source_code_atomic'

class Module
  def define_atomic_method(original_method_name)
    original_method = instance_method(original_method_name)
    if original_method.is_native?
      original_method_name # cannot transform native methods
    else
      original_method_def_src = SourceCodeReader.new.get_src_of_first_expression_in(*original_method.source_location)
      atomic_variant_source_code = SourceCodeAtomic.new.method_def_to_atomic(original_method_def_src)
      class_eval(atomic_variant_source_code)
      atomic_name_of(original_method_name)
    end
  end

  def method_is_atomic?(method_name)
    method_name.to_s.start_with? '__atomic__'
  end

  def atomic_method_nonatomic_name(atomic_method_name)
    if method_is_atomic?(atomic_method_name)
      atomic_method_name.to_s.sub(atomic_method_prefix, '').to_sym
    else
      atomic_method_name
    end
  end

  def atomic_name_of(method_name)
    method_name_atomic = atomic_method_prefix + method_name.to_s
    method_name_atomic.to_sym
  end

  private

  def atomic_method_prefix
    '__atomic__'
  end
end