require 'parser/ast/node'

require_relative '../../ruby_core_ext/symbol'

class AtomicStateAccessRewriter < Parser::AST::Processor
  def on_ivasgn(node) # e.g.: @instance_var = "some_value"
    var_name, value_node = *node

    node.updated(:send, [
        Parser::AST::Node.new(:self),
        :instance_variable_set.to_atomic_method_name,
        Parser::AST::Node.new(:sym, [var_name.to_sym]),
        process(value_node)
    ])
  end

  def on_ivar(node) # e.g.: @instance_var
    var_name = node.children.first

    node.updated(:send, [
        Parser::AST::Node.new(:self),
        :instance_variable_get.to_atomic_method_name,
        Parser::AST::Node.new(:sym, [var_name.to_sym])
    ])
  end
end