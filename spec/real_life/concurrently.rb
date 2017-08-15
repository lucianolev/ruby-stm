def concurrently(level = 20, &operation)
  threads = []
  level.times do
    threads << Thread.new do
      operation.call
    end
  end
  threads.each(&:join)
end

def force_context_switch
  sleep(0.0000001)
end