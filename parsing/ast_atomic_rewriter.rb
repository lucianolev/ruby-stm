class ASTAtomicRewriter < Parser::AST::Processor
  def on_send(node) # e.g.: obj.a_message
    receiver_node, method_name, *arg_nodes = *node

    # When accessing a variable defined in outer scope, the doesn't recognize it so it interprets it as a message
    # sent to nil. In that case we should not generate an atomic variant
    if receiver_node
      receiver_node = process(receiver_node)
      method_name = self.class.atomic_name_of(method_name)
    end

    node.updated(nil, [
        receiver_node, method_name, *process_all(arg_nodes)
    ])
  end

  def on_ivasgn(node) # e.g.: @instance_var = "some_value"
    var_name, value_node = *node

    node.updated(:send, [
        Parser::AST::Node.new(:self), :atomic_instance_variable_set,
        Parser::AST::Node.new(:sym, [var_name.to_sym]), process(value_node)
    ])
  end

  def on_ivar(node) # e.g.: @instance_var
    var_name = node.children.first

    node.updated(:send, [
        Parser::AST::Node.new(:self), :atomic_instance_variable_get,
        Parser::AST::Node.new(:sym, [var_name.to_sym])
    ])
  end
end