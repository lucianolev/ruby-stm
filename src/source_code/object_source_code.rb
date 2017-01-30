require 'parser/current'
require 'unparser'

class ObjectSourceCode

  def initialize(obj)
    @obj = obj
    @source_code = parse_source_code
    @ast = Parser::CurrentRuby.parse(@source_code)
  end

  def to_s
    @source_code
  end

  def to_ast
    @ast
  end

  def apply_ast_transformation!(ast_processor)
    @ast = ast_processor.process(to_ast)
    @source_code = Unparser.unparse(@ast)
  end

  def apply_source_rewrite!(source_rewriter)
    @source_code = source_rewriter.process
    @ast = Parser::CurrentRuby.parse(@source_code)
  end

  def new_source_rewriter
    buffer = Parser::Source::Buffer.new('(method buffer)')
    buffer.source = @source_code
    Parser::Source::Rewriter.new(buffer)
  end

  private

  def parse_source_code
    exp_src = get_source_code_expression
    parsed_node = Parser::CurrentRuby.parse(exp_src)
    source_code_node = find_source_code_node(parsed_node)
    Unparser.unparse(source_code_node)
  end

  def get_source_code_expression
    if !@obj.source_location.nil?
      file, line = @obj.source_location
      src_reader = SourceCodeReader.new
      src_reader.get_src_of_first_expression_in(file, line)
    else
      raise "Source code is not available for #{@obj}"
    end
  end

  def find_source_code_node(parsed_node)
    raise NotImplementedError
  end

end