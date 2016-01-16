require 'parser/current'
require 'unparser'
require_relative 'ast_atomic_rewriter'

class SourceCodeAtomic
  def atomic_source_of_proc(proc_definition_src)
    proc_assign_node = Parser::CurrentRuby.parse(proc_definition_src)
    body_node = get_body_node_from_proc_def(proc_assign_node)
    transformed_body_node = ASTAtomicRewriter.new.process(body_node)
    Unparser.unparse(transformed_body_node)
  end

  def atomic_source_of_method(method_def_src)
    method_def_node = Parser::CurrentRuby.parse(method_def_src)
    body_node = get_body_node_from_method_def(method_def_node)
    transformed_body_node = ASTAtomicRewriter.new.process(body_node)
    Unparser.unparse(transformed_body_node)
  end

  private

  def get_body_node_from_proc_def(proc_def_node)
    block_node = proc_def_node.children[1]
    block_node.children[2]
  end

  def get_body_node_from_method_def(method_def_node)
    method_def_node.children[2]
  end
end