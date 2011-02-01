require 'spec_helper'

# simulate railtie initialization
unless defined? TMail
  ActionMailer::Base.add_delivery_method :lettr, Lettr::MailExtensions::Lettr
end

class TestMailer < ActionMailer::Base
  def testmail

    recipients 'test@example.com'
    subject 'test subject'
    body 'test body'

  end
end

describe 'delivery method :lettr' do
  use_vcr_cassette "lettr/delivery_method", :record => :new_episodes

  before do
    ActionMailer::Base.delivery_method = :lettr
  end

  it 'should deliver a mail via lettr' do
    TestMailer.deliver_testmail
    expect { TestMailer.deliver_testmail }.to_not raise_error
  end
end
