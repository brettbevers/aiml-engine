class String
  def to_s_with_arguments(*args)
    to_s_without_arguments
  end
  alias_method :to_s_without_arguments, :to_s
  alias_method :to_s, :to_s_with_arguments
end