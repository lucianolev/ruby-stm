class Module
  def mutable_primitive_instances?
    false
  end

  def mutable_primitives(*messages)
    (@mutable_primitives ||= Set.new).merge(messages)
  end

  def is_a_mutable_primitive?(message)
    !@mutable_primitives.nil? &&
        @mutable_primitives.include?(message)
  end
end