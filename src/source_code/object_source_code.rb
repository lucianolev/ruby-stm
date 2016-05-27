require 'parser/current'
require 'unparser'

class ObjectSourceCode

  def initialize(obj)
    @source_code = parse_source_code(obj)
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

  def to_s
    @source_code
  end

  def to_ast
    if @ast.nil?
      @ast = Parser::CurrentRuby.parse(@source_code)
    end
    @ast
  end

  private

  def parse_source_code(obj)
    raise NotImplementedError
  end

end