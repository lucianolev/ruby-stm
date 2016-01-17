class UnboundMethod
  def is_native?
    source_location.nil?
  end
end