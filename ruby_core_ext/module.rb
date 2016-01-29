require_relative 'unbound_method'
require_relative '../parsing/source_code_reader'
require_relative '../parsing/source_code_atomic'

class Module
  def define_atomic_method(original_method_name)
    original_method = instance_method(original_method_name)
    if original_method.is_native?
      #puts "DEBUG: Native method #{original_method.owner}:#{original_method.name} called."
      original_method_name # cannot transform native methods
    else
      original_method_def_src = SourceCodeReader.new.get_src_of_first_expression_in(*original_method.source_location)
      atomic_variant_source_code = SourceCodeAtomic.new.method_def_to_atomic(original_method_def_src)
      class_eval(atomic_variant_source_code)
      atomic_name_of(original_method_name)
    end
  end

  def method_is_atomic?(method_name)
    method_name.to_s.start_with? atomic_method_prefix
  end

  def atomic_method_nonatomic_name(atomic_method_name)
    if method_is_atomic?(atomic_method_name)
      if is_atomic_operator?(atomic_method_name)
        operator_no_atomic(atomic_method_name)
      else
        method_name_no_atomic(atomic_method_name)
      end
    else
      atomic_method_name
    end
  end

  def atomic_name_of(method_name)
    if is_operator?(method_name)
      operator_atomic(method_name)
    else
      method_name_atomic(method_name)
    end
  end

  private

  def method_name_atomic(method_name)
    method_name_atomic = atomic_method_prefix + method_name.to_s
    method_name_atomic.to_sym
  end

  def method_name_no_atomic(method_name)
    method_name.to_s.sub(atomic_method_prefix, '').to_sym
  end

  def atomic_method_prefix
    '__atomic__'
  end

  def is_operator?(method_name)
    operators_renaming_map.has_key?(method_name)
  end

  def is_atomic_operator?(method_name)
    method_name_no_atomic_prefix = method_name_no_atomic(method_name)
    operators_renaming_map.has_value?(method_name_no_atomic_prefix)
  end

  def operator_atomic(method_name)
    method_name_atomic(operators_renaming_map[method_name])
  end

  def operator_no_atomic(method_name)
    method_name_no_atomic_prefix = method_name_no_atomic(method_name)
    operators_renaming_map.key(method_name_no_atomic_prefix)
  end

  def operators_renaming_map
    {
        :[]= => :set_index,
        :[] => :at,
        :+ => :plus,
        :- => :minus
    }
  end
end