module EasySparql

  class MockCache

    def initialize
      @cache = {}
    end

    def get(key)
      @cache[key] if @cache.has_key? key
    end

    def set(key, value)
      @cache[key] = value
    end

    def reset!
      @cache = {}
    end

  end

end
