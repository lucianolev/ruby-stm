class ASTAtomicRewriter < Parser::AST::Processor
  def on_send(node) # e.g.: obj.a_message
    receiver_node, method_name, *arg_nodes = *node

    # When accessing a variable defined in outer scope, the doesn't recognize it so it interprets it as a message
    # sent to nil. In that case we should not generate an atomic variant
    if receiver_node
      receiver_node = process(receiver_node)
      if RUBY_ENGINE == 'rbx'
        # Some Rubinius' module methods aren't real methods (they are not defined anywhere) but a mark that Rubinius
        # uses for the VM to replace that code with a C++ native call. As they're not real methoda, we should not
        # transform them. See http://stackoverflow.com/questions/20777211/what-does-rubinius-primitive-do
        unless is_a_rbx_primitive_mark(receiver_node, method_name)
          method_name = self.class.atomic_name_of(method_name)
        end
      else
        method_name = self.class.atomic_name_of(method_name)
      end
    end

    node.updated(nil, [
        receiver_node, method_name, *process_all(arg_nodes)
    ])
  end

  def on_ivasgn(node) # e.g.: @instance_var = "some_value"
    var_name, value_node = *node

    node.updated(:send, [
        Parser::AST::Node.new(:self), self.class.atomic_name_of(:instance_variable_set),
        Parser::AST::Node.new(:sym, [var_name.to_sym]), process(value_node)
    ])
  end

  def on_ivar(node) # e.g.: @instance_var
    var_name = node.children.first

    node.updated(:send, [
        Parser::AST::Node.new(:self), self.class.atomic_name_of(:instance_variable_get),
        Parser::AST::Node.new(:sym, [var_name.to_sym])
    ])
  end

  private

  def is_a_rbx_primitive_mark(receiver_node, method_name)
    primitives = [:primitive, :invoke_primitive, :check_frozen]
    receiver_node.children[1] == :Rubinius && primitives.include?(method_name)
  end

end