require_relative 'object_source_code'
require_relative 'source_code_reader'

class ProcSourceCode < ObjectSourceCode

  private

  def find_source_code_node(parsed_node)
    if parsed_node.type == :block
      block_node = parsed_node
    else
      block_node = parsed_node.children.find { |child| child.is_a?(Parser::AST::Node) && child.type == :block }
    end
    # block_node children array:
    # [0] (send
    #       (const nil :Proc) :new)
    # [1] (args)
    # [2] THE_BODY_NODE (can be any type if single-line, or ':begin' if multi-line)
    block_node.children[2]
  end
end