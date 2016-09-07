class SourceCodeReader

  def get_src_of_first_expression_in(file, linenum)
    all_lines = IO.readlines(file)
    lines_from_linenum_till_end = all_lines[linenum-1..-1]
    extract_first_expression(lines_from_linenum_till_end)
  end

  private

  def extract_first_expression(src_code_lines)
    expression = ''
    src_code_lines.each do |v|
      expression << v
      return expression if complete_expression?(expression)
    end
    raise SyntaxError, 'unexpected $end'
  end

  def complete_expression?(src_code)
    !ends_with_incomplete_line_marker?(src_code) &&
        valid_expression?(src_code)
  end

  def valid_expression?(src_code)
    begin
      catch(:valid) do
        eval("BEGIN { throw :valid }\n #{src_code}")
      end
      true
    rescue IncompleteExpressionError
      false
    end
  end

  def ends_with_incomplete_line_marker?(src_code)
    # Incomplete line markers: ',' and '\'
    src_code =~ /[,\\]\s*\z/
  end
end

class IncompleteExpressionError < SyntaxError
  # based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L124
  INCOMPLETE_EXPR_REGEX = [
      /unexpected (\$end|end-of-file|end-of-input|END_OF_FILE)/, # mri, jruby, ruby-2.0, ironruby
      /embedded document meets end of file/, # =begin
      /unterminated (quoted string|string|regexp) meets end of file/, # "quoted string" is ironruby
      /can't find string ".*" anywhere before EOF/, # rbx and jruby
      /missing 'end' for/, /expecting keyword_when/ # rbx
  ]

  INCOMPLETE_EXPR_REGEX_RBX_ONLY = [
      /expecting '[})\]]'(?:$|:)/, /expecting keyword_end/
  ]

  def self.===(exception)
    case exception.message
      when *INCOMPLETE_EXPR_REGEX
        true
      when *INCOMPLETE_EXPR_REGEX_RBX_ONLY
        RUBY_ENGINE == 'rbx'
      else
        false
    end
  end
end