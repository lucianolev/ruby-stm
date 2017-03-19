require_relative 'atomic_rewriters/atomic_state_access_rewriter'
require_relative 'atomic_rewriters/atomic_send_rewriter'

class AtomicCallable
  def self.from(callable)
    new(callable)
  end

  def initialize(callable)
    @original_callable = callable
    @atomic_callable = generate_atomic
  end

  def source_code
    source_code = original.source_code
    transform_to_atomic(source_code)
  end

  def to_atomic
    self
  end

  protected

  def generate_atomic
    raise NotImplementedError
  end

  def original
    @original_callable
  end

  def transform_to_atomic(source_code)
    atomic_send_transformation!(source_code)
    atomic_state_access_transformation!(source_code)
    source_code
  end

  def atomic_state_access_transformation!(source_code)
    state_access_rewriter = AtomicStateAccessRewriter.new
    source_code.apply_ast_transformation!(state_access_rewriter)
  end

  def atomic_send_transformation!(source_code)
    send_rewriter = atomic_send_rewriter
    source_code.apply_ast_transformation!(send_rewriter)
  end

  def atomic_send_rewriter
    AtomicSendRewriter.new
  end

  def method_missing(symbol, *args)
    @atomic_callable.send(symbol, *args)
  end
end