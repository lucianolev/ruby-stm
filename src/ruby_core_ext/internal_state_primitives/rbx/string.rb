class String
  private

  def start_new_copy
    Rubinius.invoke_primitive :string_dup, self
  end
end