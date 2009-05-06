class ActiveSupport::BufferedLogger
  def add_with_backtrace(severity, message = nil, progname = nil, &block)
    if message.is_a?(Exception)
      add_without_backtrace(severity, "Exception: #{message.message}", progname)
      message.backtrace.each { |trace| add_without_backtrace(severity, "  #{trace}", progname) }
    else
      add_without_backtrace(severity, message, progname, &block)
    end
  end
  alias_method_chain :add, :backtrace
end
