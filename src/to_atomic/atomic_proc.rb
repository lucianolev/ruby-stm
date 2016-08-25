require_relative 'ast_atomic_rewriter'

class AtomicProc

  def self.of(a_proc)
    new(a_proc)
  end

  def initialize(a_proc)
    @original_proc = a_proc
    @atomic_proc = Proc.new do
      a_proc.binding.eval(source_code.to_s,
                          *@original_proc.source_location)
    end
  end

  def source_code
    source_code = @original_proc.source_code
    ast_rewriter = ASTAtomicRewriter.new(@original_proc.binding)
    source_code.apply_ast_transformation!(ast_rewriter)
    source_code
  end

  def to_atomic
    self
  end

  private

  def method_missing(symbol, *args)
    @atomic_proc.send(symbol, *args)
  end

end