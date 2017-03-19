require_relative '../../ruby_core_ext/symbol'
require_relative 'local_vars_in_scope'

class AtomicSendRewriter < Parser::AST::Processor
  def initialize(a_binding=nil)
    if !a_binding.nil?
      @local_vars_in_scope = LocalVarsInScope.new(a_binding)
    else
      @local_vars_in_scope = Set.new
    end
  end

  def on_send(node) # e.g.: obj.a_message
    receiver_node, method_name, *arg_nodes = *node

    receiver_node = process(receiver_node) if receiver_node

    if should_transform_to_atomic?(node)
      method_name = method_name.to_atomic_method_name
    end

    # continue processing...
    node.updated(nil, [
        receiver_node, method_name, *process_all(arg_nodes)
    ])
  end

  private

  def should_transform_to_atomic?(send_node)
    _, method_name, *_ = *send_node

    # When accessing a local variable defined in outer scope, the parser cannot distinguish it from a message sent
    # without arguments and an explicit receiver. We should check if this send node corresponds to a local variable
    # gathered from current scope (on initialization)
    !@local_vars_in_scope.include?(method_name)
  end
end