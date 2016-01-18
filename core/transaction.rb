require_relative 'object_change'

class Transaction
  def do(atomic_block)
    $current_transaction = self
    self.begin
    result = atomic_block.call
    commit
    result
  end

  def begin
    @object_changes = {}
  end

  def commit
    @object_changes.each_value do |change|
      if change.has_conflict?
        raise
      end
    end
    @object_changes.each_value do |change|
      if change.has_changed?
        change.apply
      end
    end
    nil
  end

  def change_for(an_object)
    unless @object_changes.has_key?(an_object)
      @object_changes[an_object] = ObjectChange.new(an_object)
    end
    @object_changes[an_object]
  end
end