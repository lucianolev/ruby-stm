module Process
  @atomic_commit_semaphore = Mutex.new

  def self.atomic_commit_lock
    @atomic_commit_semaphore.lock
  end

  def self.atomic_commit_unlock
    @atomic_commit_semaphore.unlock
  end
end