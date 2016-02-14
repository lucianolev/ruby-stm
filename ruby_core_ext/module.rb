require_relative 'unbound_method'
require_relative '../parsing/source_code_atomic_transformer'

class Module

  # In the Smalltalk implementation, this is done in conjunction with ACCompiler>>atomicMethod:missing: and
  # CompiledMethod. In Ruby, it makes more sense to do it in Module, as it has already a method colled 'define_method'
  # to define new methods.
  def define_atomic_method(original_method_name)
    original_method = instance_method(original_method_name)
    if original_method.is_native?
      #puts "DEBUG: Native method #{original_method.owner}:#{original_method.name} called."
      define_method(atomic_name_of(original_method_name), original_method)
    else
      #puts 'DEBUG: New atomic method defined: ', atomic_variant_source_code
      atomic_method_definition = SourceCodeAtomicTransformer.new.transform_method_definition(original_method.definition)
      class_eval(atomic_method_definition)
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
        :- => :minus,
        :* => :asterisk,
        :/ => :slash,
        :> => :greater_than,
        :< => :less_than,
        :>= => :greater_or_eq_than,
        :<= => :less_or_eq_than,
        :== => :double_equal_sign,
        :<< => :shift_left,
        :>> => :shift_right
    }
  end
end