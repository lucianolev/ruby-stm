require 'parser/current'
require 'unparser'
require_relative 'ast_atomic_rewriter'
require_relative '../ruby_core_ext/module'

class SourceCodeAtomicTransformer
  def transform_source_code(source_code)
    source_root_node = Parser::CurrentRuby.parse(source_code)
    transformed_root_node = ASTAtomicRewriter.new.process(source_root_node)
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
    method_name = method_def_node.children.find { |child| child.is_a?(Symbol) }
    rewriter.replace(method_def_node.location.name, self.class.atomic_name_of(method_name).to_s)
    rewriter.process
  end

end