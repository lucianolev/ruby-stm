# load all ruby_core_ext
if RUBY_ENGINE == 'rbx'
  Dir[File.join(__dir__, 'custom_atomic_methods/rbx', '*.rb')].each { |file| require_relative file }
end

require_relative 'object'
require_relative '../source_code/proc_source_code'
require_relative '../core/memory_transaction'
require_relative '../to_atomic/atomic_proc'

class Proc
  def atomic
    MemoryTransaction.do(to_atomic)
  end

  def atomic_if_conflict(a_block)
    MemoryTransaction.do_if_conflict(to_atomic, a_block)
  end

  def atomic_retry
    MemoryTransaction.do_and_retry(to_atomic)
  end

  def to_atomic
    AtomicProc.of(self)
  end

  def source_code
    ProcSourceCode.new(self)
  end
end