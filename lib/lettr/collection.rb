class Lettr::Collection
  def initialize collection, context
    @collection = collection
    @vars = []
    @context = context
  end

  def add_variable var
    @vars << var
  end

  def evaluate
    @collection.each do |element|
      hash = {}
      @vars.each do |var|
        var = var.split('.').last
        if element.class.respond_to? :is_whitelisted?
          raise SecurityError, "method #{var} in class #{element.class} not whitelisted" unless element.class.is_whitelisted?(var)
        end
        hash[var] = element.send(var)
      end
      @context << hash
    end

  end
end


