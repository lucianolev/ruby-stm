require_relative 'object_source_code'
require_relative 'source_code_reader'

class UnboundMethodSourceCode < ObjectSourceCode

  def initialize(obj)
    super
    remove_method_receiver_if_present!
  end

  def name_in_definition
    to_ast.children[0]
  end

  def change_name_in_definition!(new_name)
    source_rewriter = new_source_rewriter
    source_rewriter.replace(to_ast.location.name, new_name.to_s)
    apply_source_rewrite!(source_rewriter)
  end

  private

  def remove_method_receiver_if_present!
    source_rewriter = new_source_rewriter
    dot_separator = to_ast.location.operator
    unless dot_separator.nil?
      node_before_dot = to_ast.children.first
      source_rewriter.remove(node_before_dot.location.expression)
      source_rewriter.remove(dot_separator)
    end
    apply_source_rewrite!(source_rewriter)
  end

  def parse_source_code(a_method)
    source_location = a_method.source_location
    method_def_src = SourceCodeReader.new.get_src_of_first_expression_in(*source_location)
    method_def_node = get_method_def_node(a_method, method_def_src)
    Unparser.unparse(method_def_node)
  end

  def get_method_def_node(a_method, method_def_src)
    guessed_method_def_node = Parser::CurrentRuby.parse(method_def_src)
    if is_an_attr_def_node?(guessed_method_def_node)
      generate_attr_method(a_method)
    else
      method_def_node = search_for_method_def_node(guessed_method_def_node)
      unless method_def_node
        raise "Could not find definition for #{a_method}"
      end
      method_def_node
    end
  end

  def generate_attr_method(attr_method)
    if attr_method.name.is_an_assign_ivar_method_name?
      ivar_name = "@#{attr_method.name.to_s[0..-2]}".to_sym # removes the '=' at the end
      generate_ivar_writer_method(ivar_name)
    else
      ivar_name = "@#{attr_method.name.to_s}".to_sym
      generate_ivar_reader_method(ivar_name)
    end
  end

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

end