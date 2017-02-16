# -*- encoding: utf-8 -*-
require 'rest_cli'

class Pingxx < RestCli
  
  def initialize(configs)
    configs.symbolize_keys!
    configs.assert_valid_keys(:key, :secret, :host, :protocol, :private_key, :public_key)

    @params = {
      app: { id: configs.delete(:key) },
      currency: 'cny'
    }

    @private_key = OpenSSL::PKey.read configs.delete(:private_key) if configs.has_key?(:private_key)
    @public_key  = OpenSSL::PKey.read configs.delete(:public_key)  if configs.has_key?(:public_key)

    super('https://api.pingxx.com/v1')
  end

  def payment(billing)
    billing.symbolize_keys!
    billing.assert_valid_keys(:order_no, :amount, :channel, :client_ip, :subject, :body, :metadata, :time_expire)

    headers = { content_type: 'application/json' }
    
    billing[:time_expire] ||= 15.minutes.from_now.to_i
    billing[:amount]      = billing.delete(:amount) * 100 # 单位为分

    payload = billing.merge(@params).to_json

    headers[:pingplusplus_signature] = signature(payload) if @private_key

    self.post('charges', payload, headers)
  end

  def verify(signature, raw_data)
    @public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), raw_data)
  end

  private

    def signature(payload)
      Base64.strict_encode64 @private_key.sign(OpenSSL::Digest::SHA256.new, payload)
    end
end