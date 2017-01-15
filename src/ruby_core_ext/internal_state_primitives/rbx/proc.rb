class Proc
  private

  def start_new_copy
    self.class.__allocate__
  end
end