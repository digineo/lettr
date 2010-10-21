class NewsletterBoy::Collection
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
        hash[var] = element.send(var)
      end
      @context << hash
    end

  end
end

