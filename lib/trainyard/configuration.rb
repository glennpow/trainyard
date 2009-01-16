class Configuration
  cattr_accessor :load_path
  
  self.load_path = [ File.dirname(__FILE__) + "/../config.yml" ]
  
  def self.configs
    @@configs ||= self.load_path.inject({}) { |hash, file| hash.merge(YAML::load_file(file)[RAILS_ENV]) }
  end
    
  def self.method_missing(symbol, *args)
    self.configs[symbol.to_s] || args.first
  end
end
