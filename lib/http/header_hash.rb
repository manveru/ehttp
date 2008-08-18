module HTTP
  class HeaderHash < Hash
    def initialize(hash = {})
      hash.each{|key, value| self[key] = value }
    end

    def to_hash
      {}.replace(self)
    end

    def [](key)
      super capitalize(key)
    end

    def []=(key, value)
      super capitalize(key), value
    end

    def capitalize(key)
      key.to_s.downcase.gsub(/\b\w/){|s| s.upcase! }
    end
  end
end
