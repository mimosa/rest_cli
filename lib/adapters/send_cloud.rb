# -*- encoding: utf-8 -*-
require 'rest_cli'

class SendCloud < RestCli
  def initialize(key, secret)
    @params = {
      apiUser: key,
      apiKey: secret
    }

    super('https://api.sendcloud.net/apiv2')
  end

  def send_template(mails, templ_name, from, attachments = nil)
    params = {
      from: from,
      templateInvokeName: templ_name,
      xsmtpapi: gen_xsmtpapi(mails),
      useNotification: true
    }
    # 附件
    params[:attachments] = attachments unless attachments.nil?

    resp = send_mail(params, 'mail/sendtemplate')
    resp && resp[:result]
  end

  def send(mails, subject, body, from, attachments = nil)
    params = {
      from: from,
      subject: subject,
      html: body,
      xsmtpapi: gen_xsmtpapi(mails),
      useNotification: true
    }
    # 附件
    params[:attachments] = attachments unless attachments.nil?

    resp = send_mail(params)
    resp && resp[:result]
  end

  private

  def gen_xsmtpapi(mails)
    xsmtpapi = {
      to: [],
      sub: {}
    }

    mails.each do |to, attrs|
      xsmtpapi[:to] << to

      attrs&.each do |key, val|
        key = "%#{key}%"
        xsmtpapi[:sub][key] = [] unless xsmtpapi[:sub].key?(key)
        xsmtpapi[:sub][key] << (val || '')
      end
    end

    MultiJson.dump(xsmtpapi)
  end

  def send_mail(params, path = 'mail/send')
    self.post(path, @params.merge(params))
  end
end
