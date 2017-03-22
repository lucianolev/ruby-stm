class Module
  def infrastructure_primitives(*method_names)
    (@infrastructure_primitives ||= Set.new).merge(method_names)
  end

  def is_infraestructure_primitive?(method_name)
    !@infrastructure_primitives.nil? &&
        @infrastructure_primitives.include?(method_name)
  end
end