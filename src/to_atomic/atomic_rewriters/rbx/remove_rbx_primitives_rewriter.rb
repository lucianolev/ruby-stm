class RemoveRbxPrimitivesRewriter < Parser::AST::Processor
  def initialize(source_rewriter)
    @source_rewriter = source_rewriter
  end

  def do(ast)
    process(ast)
    @source_rewriter
  end

  def on_send(node) # e.g.: obj.a_message
    if is_a_rbx_primitive_call_node?(node)
      @source_rewriter.remove(node.location.expression)
    end

    super
  end

  def is_a_rbx_primitive_call_node?(node)
    receiver_node, method_name, *_ = *node

    !receiver_node.nil? && receiver_node.children[1] == :Rubinius &&
        method_name == :primitive
  end
end