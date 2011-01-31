module Lettr::ActionMailer

  private

  def perform_delivery_lettr mail
    Mail::Lettr.new(:template => @template).deliver! mail
  end

end
