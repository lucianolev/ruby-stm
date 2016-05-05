require 'parser/current'
require 'unparser'
require_relative '../ruby_core_ext/symbol'

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
    method_def_src = get_src_of_first_expression_in(*source_location)
    guessed_method_def_node = Parser::CurrentRuby.parse(method_def_src)
    if is_an_attr_def_node?(guessed_method_def_node)
      if a_method.name.is_an_assign_ivar_method_name?
        ivar_name = "@#{a_method.name.to_s[0..-2]}".to_sym # removes the '=' at the end
        method_def_node = generate_ivar_writer_method(ivar_name)
      else
        ivar_name = "@#{a_method.name.to_s}".to_sym
        method_def_node = generate_ivar_reader_method(ivar_name)
      end
    else
      method_def_node = search_for_method_def_node(guessed_method_def_node)
      unless method_def_node
        raise "Could not find definition for #{a_method}"
      end
    end
    Unparser.unparse(method_def_node)
  end

  private

  def search_for_method_def_node(ast_node)
    if is_a_method_def_node?(ast_node)
      ast_node
    else
      ast_node.children.find(ifnone=false) do |child|
        child.is_a?(Parser::AST::Node) && is_a_method_def_node?(child)
      end
    end
  end

  def is_a_method_def_node?(ast_node)
    ast_node.type == :def || ast_node.type == :defs
  end

  def is_an_attr_def_node?(ast_node)
    ast_node.type == :send && [:attr_accessor, :attr_reader, :attr_writer].include?(ast_node.children[1])
  end

  def generate_ivar_reader_method(ivar_name)
    new_method_name = ivar_name.to_s[1..-1].to_sym # removes the @ sign at the beginning
    no_args_node = Parser::AST::Node.new(:args)
    read_ivar_body_node = Parser::AST::Node.new(:ivar, [ivar_name])
    Parser::AST::Node.new(:def, [new_method_name, no_args_node, read_ivar_body_node])
  end

  def generate_ivar_writer_method(ivar_name)
    new_method_name = "#{ivar_name.to_s[1..-1].to_sym}=" # removes the @ sign at the beginning and adds '=' at the end
    args_node = Parser::AST::Node.new(:args, [Parser::AST::Node.new(:arg, [:value])])
    write_ivar_body_node = Parser::AST::Node.new(:ivasgn,
                                                 [ivar_name, Parser::AST::Node.new(:lvar, [:value])])
    Parser::AST::Node.new(:def, [new_method_name, args_node, write_ivar_body_node])
  end

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
end

# based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L124
class IncompleteExpression
  GENERIC_REGEXPS = [
      /unexpected (\$end|end-of-file|end-of-input|END_OF_FILE)/, # mri, jruby, ruby-2.0, ironruby
      /embedded document meets end of file/, # =begin
      /unterminated (quoted string|string|regexp) meets end of file/, # "quoted string" is ironruby
      /can't find string ".*" anywhere before EOF/, # rbx and jruby
      /missing 'end' for/, /expecting keyword_when/ # rbx
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