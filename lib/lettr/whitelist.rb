module Lettr::Whitelist

  def self.extended model
    model.class_inheritable_accessor :lettr_whitelist
    model.lettr_whitelist ||= []
  end

  # fügt methoden zur whitelist hinzu
  # nb_white_list :number, :test, :name
  def lettr_white_list *args
    self.lettr_whitelist = args.map(&:to_s)
  end

  def is_whitelisted? method
    lettr_whitelist.include? method.to_s
  end
end
