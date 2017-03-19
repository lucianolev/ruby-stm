require_relative 'atomic_callable'

class AtomicProc < AtomicCallable
  private

  def generate_atomic
    Proc.new do
      original.binding.eval(source_code.to_s,
                            *original.source_location)
    end
  end

  def atomic_send_rewriter
    AtomicSendRewriter.new(original.binding)
  end
end