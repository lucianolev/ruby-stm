require_relative 'ast_atomic_rewriter'

class AtomicUnboundMethod

  def self.of(unbound_method)
    new(unbound_method)
  end

  def initialize(unbound_method)
    @original_method = unbound_method
  end

  def name
    @original_method.name.to_atomic_method_name
  end

  def source_code
    method_src_code = @original_method.source_code
    method_src_code.change_name_in_definition!(name)
    method_src_code.apply_ast_transformation!(ASTAtomicRewriter.new)
    method_src_code
  end

  def to_atomic
    self
  end

  def define_in(a_module)
    if can_transform_original_to_atomic?
      a_module.send(:define_method_using_source_code, self.name,
                    source_code)
    else
      a_module.send(:define_method, self.name,
                    @original_method)
    end
  end

  private

  def can_transform_original_to_atomic?
    @original_method.source_code_available?
  end

  def method_missing(symbol, *args)
    @original_method.send(symbol, *args)
  end

end