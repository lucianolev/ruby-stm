class ASTAtomicRewriter < Parser::AST::Processor
  def initialize(a_binding=nil)
    @source_binding = a_binding
  end

  def on_send(node) # e.g.: obj.a_message
    receiver_node, method_name, *arg_nodes = *node

    receiver_node = process(receiver_node) if receiver_node

    # When accessing a local variable defined in outer scope, the parser cannot distinguish it from a message sent
    # wihout arguments and without an explicit receiver. In that case we can desambiguate the situation by looking
    # if the supposed 'method_name' is not indeed a local variable. So, we do the atomic name transformation unless
    # it's a local variable.
    unless is_a_local_variable(method_name)
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

  def is_a_local_variable(method_name)
    begin
      !@source_binding.nil? and @source_binding.local_variable_defined?(method_name)
    rescue NameError # some method name are not valid local variable names so local_variable_defined? will raise a NameError
      false
    end
  end

end