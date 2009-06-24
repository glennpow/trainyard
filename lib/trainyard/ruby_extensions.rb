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

class Fixnum
  def true?
    !self.zero?
  end
end

class String
  def to_class
    self.camelize.constantize
  end
  
  def true?
    self == "1" || self == "true"
  end
end

class TrueClass
  def true?
    true
  end
end

class FalseClass
  def true?
    false
  end
end

class NilClass
  def true?
    false
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