module Mail
  class Lettr

    def initialize(values={})
      @settings = values
    end

    def deliver!(mail)
      lettr_request_hashes = []
      raise 'no recipient' unless mail.to
      mail.to.each do |recipient|
        lettr_request_hash = {}
        lettr_request_hash[:recipient] = recipient
        lettr_request_hash[:subject] = mail.subject
        if mail.parts.empty?
          case mail.content_type
          when /text\/html/
            lettr_request_hash[:html] = mail.body
          when /text\/plain/
            lettr_request_hash[:text] = mail.body
          end
        else
          mail.parts.each do |part|
            case part.content_type
            when /text\/html/
              lettr_request_hash[:html] = part.body
            when /text\/plain/
              lettr_request_hash[:text] = part.body
            else
              lettr_request_hash[:attachments] ||= []
              lettr_request_hash[:attachments] << part.body
            end
          end
        end
        lettr_request_hashes << lettr_request_hash
      end
      identifier = @settings[:template] || mail.subject.downcase.gsub(/\s/, '_')
      lettr_request_hashes.each do |lettr_request_hash|
        ::Lettr.send(identifier, lettr_request_hash).deliver
      end
    end
  end

end
