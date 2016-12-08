require_relative '../ruby_core_ext/thread'
require_relative 'object_change'

class MemoryTransaction
  private_class_method :new

  def self.do_if_conflict(atomic_proc, on_conflict_proc)
    new.do_if_conflict(atomic_proc, on_conflict_proc)
  end

  def self.do(atomic_proc)
    self.do_if_conflict(atomic_proc, MemoryTransaction.signal_conflict_block)
  end

  def self.do_and_retry(atomic_proc)
    self.do_if_conflict(atomic_proc, Proc.new { self.do_and_retry(atomic_proc) })
  end

  def self.current
    unless is_there_a_transaction_running?
      raise 'No current transaction!'
    end
    Thread.current_transaction
  end

  def self.is_there_a_transaction_running?
    Thread.is_there_a_current_transaction_registered?
  end

  def do_if_conflict(atomic_proc, on_conflict_proc)
    Thread.register_current_transaction(self)
    begin
      result = atomic_proc.call
    ensure
      Thread.unregister_current_transaction
    end
    commit_if_conflict(on_conflict_proc)
    result
  end

  def change_for(an_object)
    @object_changes[an_object] ||= ObjectChange.new(an_object)
  end

  private

  def initialize
    @object_changes = {}
  end

  def commit
    commit_if_conflict(MemoryTransaction.signal_conflict_block)
  end

  def commit_if_conflict(on_conflict_block)
    MemoryTransaction.commit_lock
    @object_changes.each_value do |change|
      if change.has_conflict?
        MemoryTransaction.commit_unlock
        return on_conflict_block.call(change.original)
      end
    end
    @object_changes.each_value do |change|
      if change.has_changed?
        change.apply
      end
    end
    MemoryTransaction.commit_unlock
    nil
  end

  def self.signal_conflict_block
    Proc.new do |conflicting_obj|
      raise "CommitConflict: #{conflicting_obj} was changed during current transaction."
    end
  end

  @commit_semaphore = Mutex.new

  def self.commit_lock
    @commit_semaphore.lock
  end

  def self.commit_unlock
    @commit_semaphore.unlock
  end
end