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

  def method_def_to_atomic(method_def_src)
    method_def_src = method_def_with_atomic_prefix(method_def_src)
    method_def_node = Parser::CurrentRuby.parse(method_def_src)
    transformed_body_node = ASTAtomicRewriter.new.process(method_def_node)
    Unparser.unparse(transformed_body_node)
  end

  private

  def method_def_with_atomic_prefix(method_def_src)
    method_def_node = Parser::CurrentRuby.parse(method_def_src)
    buffer = Parser::Source::Buffer.new('(method buffer)')
    buffer.source = method_def_src
    rewriter = Parser::Source::Rewriter.new(buffer)
    rewriter.insert_before(method_def_node.location.name, self.class.atomic_method_prefix)
    rewriter.process
  end

  def get_body_node_from_proc_def(proc_def_node)
    block_node = proc_def_node.children[1]
    block_node.children[2]
  end
end