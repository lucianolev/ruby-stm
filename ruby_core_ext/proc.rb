require_relative 'object'
require_relative '../parsing/source_code_reader'
require_relative '../parsing/source_code_atomic'
require_relative '../core/transaction'

class Proc
  def atomic
    Transaction.new.do(to_atomic)
  end

  private

  def to_atomic
    proc_def_src = SourceCodeReader.new.get_src_of_first_expression_in(*source_location)
    atomic_block_src = SourceCodeAtomic.new.atomic_source_of_proc(proc_def_src)
    self.class.new do
      eval(atomic_block_src)
    end
  end
end