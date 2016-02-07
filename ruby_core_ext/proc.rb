require_relative 'object'
require_relative '../parsing/source_code_parser'
require_relative '../parsing/source_code_atomic_transformer'
require_relative '../core/transaction'

class Proc
  def atomic
    Transaction.new.do(to_atomic)
  end

  def atomic_if_conflict(a_block)
    Transaction.new.do_if_conflict(to_atomic, a_block)
  end

  def atomic_retry
    Transaction.new.retry(to_atomic)
  end

  def source_code
    SourceCodeParser.new.get_proc_source_code(self)
  end

  private

  def to_atomic
    atomic_block_src = SourceCodeAtomicTransformer.new.transform_source_code(self.source_code)
    self.class.new do
      binding.eval(atomic_block_src)
    end
  end
end