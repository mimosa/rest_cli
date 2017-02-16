# -*- encoding: utf-8 -*-
require 'rest_cli'

class Mailgun < RestCli
  def initialize(key)
    super('https://api.mailgun.net/v3')
    connection.basic_auth('api', key)
  end

  def send(to, subject, body, from)
    params = {
      from: from,
      subject: subject,
      text: body,
      html: body,
      to: to
    }
    
    send_mail(params)
  end

  def set_domain(domain)
    @domain = domain
  end
  alias_method :domain=, :set_domain

  private

    def send_mail(params)
      return false if @domain.nil?
      self.post("#{@domain}/messages", params)
    end
end