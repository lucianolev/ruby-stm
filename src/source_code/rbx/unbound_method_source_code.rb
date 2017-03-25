require_relative '../../ruby_core_ext/rbx/unbound_method'

class UnboundMethodSourceCode < ExecutableSourceCode

  # WORKAROUND: Rubinius's source_location method returns nil for attr_* methods.
  # See https://github.com/rubinius/rubinius/issues/3727
  # This generates the needed source expression dinamically for those cases.
  # Please remove when the bug is fixed.

  def get_source_code_expression
    if @obj.source_location.nil? && @obj.is_attr_reader?
      method_name = @obj.name
      return "attr_reader :#{method_name}"
    end
    if @obj.source_location.nil? && @obj.is_attr_writer?
      del_eq_sign = Proc.new { |sym| sym.to_s.lstrip[0..-2].to_sym }
      method_name = del_eq_sign.call(@obj.name)
      return "attr_writer :#{method_name}"
    end

    super
  end

end