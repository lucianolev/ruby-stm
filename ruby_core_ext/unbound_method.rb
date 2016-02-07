require_relative '../parsing/source_code_parser'

class UnboundMethod
  def is_native?
    source_location.nil?
  end

  def definition
    if is_native?
      raise 'Cannot get source code of a native method.'
    end
    SourceCodeParser.new.get_method_definition(self)
  end
end