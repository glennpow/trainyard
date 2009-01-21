class Object
  def rsend(*args, &block)
    if args.length == 1 && args.first.is_a?(Array)
      args = args.first
    end
    obj = self
    args.each do |a|
      b = (a.is_a?(Array) && a.last.is_a?(Proc) ? a.pop : block)
      obj = obj.__send__(*a, &b)
    end
    obj
  end
  alias_method :__rsend__, :rsend
  
  def metaclass
    class << self; self; end;
  end
  
  def meta_eval &blk
    metaclass.instance_eval &blk
  end

  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end

  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end

class String
  def to_class
    self.camelize.constantize
  end
end

class Hash
  def deep_dup
    target = {}
    self.keys.each do |key|
      if self[key].is_a?(Hash)
        target[key] = self[key].deep_dup
      else
        target[key] = self[key]
      end
    end
    target
  end
end