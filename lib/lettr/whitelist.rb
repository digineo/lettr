module NewsletterBoy::Whitelist

  def self.extended model
    model.class_inheritable_accessor :nb_whitelist
    model.nb_whitelist ||= []
  end

  # fügt methoden zur whitelist hinzu
  # nb_white_list :number, :test, :name
  def nb_white_list *args
    self.nb_whitelist = args.map(&:to_s)
  end

  def is_whitelisted? method
    nb_whitelist.include? method.to_s
  end
end
