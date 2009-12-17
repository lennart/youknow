module MorphableDocument

  def self.included(base)
    raise "Cannot Include, since `to_hash` method is missing from #{base}" unless base.instance_methods.map{|m| m.to_sym }.include? :to_hash
    base.send :include, InstanceMethods
  end
  module InstanceMethods
  def morph_to(klass)
    klass.new self.to_hash
  end
  end
end
