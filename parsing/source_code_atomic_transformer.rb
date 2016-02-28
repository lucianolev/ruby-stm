require 'parser/current'
require 'unparser'
require_relative '../ruby_core_ext/symbol'
require_relative 'ast_atomic_rewriter'

class SourceCodeAtomicTransformer
  def transform_source_code(source_code)
    transform_source_code_with_binding(source_code, nil)
  end

  def transform_source_code_with_binding(source_code, source_binding)
    source_root_node = Parser::CurrentRuby.parse(source_code)
    transformed_root_node = ASTAtomicRewriter.new(source_binding).process(source_root_node)
    Unparser.unparse(transformed_root_node)
  end

  def transform_method_definition(method_def_src)
    method_def_src = method_def_with_atomic_prefix(method_def_src)
    transform_source_code(method_def_src)
  end

  private

  def method_def_with_atomic_prefix(method_def_src)
    method_def_node = Parser::CurrentRuby.parse(method_def_src)
    buffer = Parser::Source::Buffer.new('(method buffer)')
    buffer.source = method_def_src
    rewriter = Parser::Source::Rewriter.new(buffer)
    remove_method_receiver_if_present(method_def_node, rewriter)
    replace_method_name_with_atomix_prefix(method_def_node, rewriter)
    rewriter.process
  end

  def replace_method_name_with_atomix_prefix(method_def_node, rewriter)
    method_name = method_def_node.children.find { |child| child.is_a?(Symbol) }
    rewriter.replace(method_def_node.location.name, method_name.to_atomic_method_name.to_s)
  end

  def remove_method_receiver_if_present(method_def_node, rewriter)
    dot_separator = method_def_node.location.operator
    unless dot_separator.nil?
      node_before_dot = method_def_node.children.first
      rewriter.remove(node_before_dot.location.expression)
      rewriter.remove(dot_separator)
    end
  end

end