require_relative 'object_source_code'
require_relative 'source_code_reader'

class ProcSourceCode < ObjectSourceCode

  private

  def parse_source_code(a_proc)
    source_location = a_proc.source_location
    proc_definition = SourceCodeReader.new.get_src_of_first_expression_in(*source_location)
    proc_assign_node = Parser::CurrentRuby.parse(proc_definition)
    body_node = get_body_node_from_proc_def(proc_assign_node)
    Unparser.unparse(body_node)
  end

  def get_body_node_from_proc_def(proc_def_node)
    if proc_def_node.type == :block
      block_node = proc_def_node
    else
      block_node = proc_def_node.children.find { |child| child.is_a?(Parser::AST::Node) && child.type == :block }
    end
    # block_node children array:
    # [0] (send
    #       (const nil :Proc) :new)
    # [1] (args)
    # [2] THE_BODY_NODE (can be any type if single-line, or ':begin' if multi-line)
    block_node.children[2]
  end
end