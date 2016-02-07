require 'parser/current'
require 'unparser'

class SourceCodeParser

  def get_proc_source_code(a_proc)
    source_location = a_proc.source_location
    proc_definition = get_src_of_first_expression_in(*source_location)
    proc_assign_node = Parser::CurrentRuby.parse(proc_definition)
    body_node = get_body_node_from_proc_def(proc_assign_node)
    Unparser.unparse(body_node)
  end

  def get_method_definition(a_method)
    source_location = a_method.source_location
    get_src_of_first_expression_in(*source_location)
  end

  private

  def get_src_of_first_expression_in(file, linenum)
    lines = IO.readlines(file)
    lines_from_linenum = lines[linenum-1..-1]
    extract_first_expression(lines_from_linenum)
  end

  # based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L92
  def extract_first_expression(lines)
    code = ''
    lines.each do |v|
      code << v
      return code if complete_expression?(code)
    end
    raise SyntaxError, 'unexpected $end'
  end

  # based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L66
  def complete_expression?(str)
    catch(:valid) do
      eval("BEGIN{throw :valid}\n#{str}")
    end

    # Assert that a line which ends with a , or \ is incomplete.
    str !~ /[,\\]\s*\z/
  rescue IncompleteExpression
    false
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

  # def get_body_node_from_method_def(method_def_node)
  #   args_node_index = method_def_node.children.find_index { |child| child.is_a?(Parser::AST::Node) && child.type == :args }
  #   # method_def_node children array:
  #   # [0..n-1] ?
  #   # [n] (args)
  #   # [n+1] THE_BODY_NODE (can be any type if single-line, or ':begin' if multi-line)
  #   method_def_node.children[args_node_index+1]
  # end
end

# based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L124
class IncompleteExpression
  GENERIC_REGEXPS = [
      /unexpected (\$end|end-of-file|end-of-input|END_OF_FILE)/, # mri, jruby, ruby-2.0, ironruby
      /embedded document meets end of file/, # =begin
      /unterminated (quoted string|string|regexp) meets end of file/, # "quoted string" is ironruby
      /can't find string ".*" anywhere before EOF/, # rbx and jruby
      /missing 'end' for/, /expecting kWHEN/ # rbx
  ]

  RBX_ONLY_REGEXPS = [
      /expecting '[})\]]'(?:$|:)/, /expecting keyword_end/
  ]

  def self.===(ex)
    return false unless SyntaxError === ex
    case ex.message
      when *GENERIC_REGEXPS
        true
      when *RBX_ONLY_REGEXPS
        rbx?
      else
        false
    end
  end

  def self.rbx?
    RbConfig::CONFIG['ruby_install_name'] == 'rbx'
  end
end