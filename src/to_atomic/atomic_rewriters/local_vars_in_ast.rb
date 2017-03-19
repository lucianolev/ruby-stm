require 'parser'

class LocalVarsInAST < Parser::AST::Processor
  def initialize
    @local_vars_in_ast = Set.new
  end

  def add_from_tree(root_node)
    process(root_node)
  end

  def on_lvasgn(node) # e.g.: local_var = "some_value"
    var_name, _ = *node
    @local_vars_in_ast.add(var_name)

    # continue processing...
    on_vasgn(node)
  end

  def include?(var_name)
    @local_vars_in_ast.include?(var_name)
  end
end