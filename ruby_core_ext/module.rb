require_relative 'unbound_method'

class Module
  def define_atomic_method(original_method_name)
    original_method = instance_method(original_method_name)
    if original_method.is_native?
      original_method_name # cannot transform native methods
    else
      atomic_source_code = Proc.new do
        eval(original_method.atomic_source_code)
      end
      define_method(atomic_name_of(original_method_name), &atomic_source_code)
      atomic_name_of(original_method_name)
    end
  end

  def method_is_atomic?(method_name)
    method_name.to_s.start_with? '__atomic__'
  end

  def atomic_method_nonatomic_name(atomic_method_name)
    if method_is_atomic?(atomic_method_name)
      atomic_method_name.to_s.sub('__atomic__', '').to_sym
    else
      atomic_method_name
    end
  end

  private

  def atomic_name_of(method_name)
    method_name_atomic = '__atomic__' + method_name.to_s
    method_name_atomic.to_sym
  end
end