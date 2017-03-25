require_relative 'atomic_rewriters/atomic_state_access_rewriter'
require_relative 'atomic_rewriters/atomic_send_rewriter'

class AtomicExecutable
  def self.from(executable)
    new(executable)
  end

  def initialize(executable)
    @original_exec = executable
    @atomic_exec = generate_atomic
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
    @original_exec
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
    @atomic_exec.send(symbol, *args)
  end
end