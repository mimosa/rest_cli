# -*- encoding: utf-8 -*-
require 'rest_cli'

class FaceShape < RestCli
  def initialize
    super('http://103.41.53.115:8080')
  end

  def get(url)
    data = shape(url)
    if data.nil? || data[:face].empty?
      data = { is_shape: false }
    else
      data.merge!(data.delete(:face))
      # 数据扁平化处理
      data.merge!(data.delete(:attribute).delete(:faceShape))
      data.merge!(data.delete(:position))

      if data.has_key?(:forehead_center) && data[:forehead_center].values.min == 0.0
        data.delete(:forehead_center)
      end
    end
    data
  end

  private

    def shape(url)
      self.request(:get, '/faceinfo', { url: url }, { accept: 'application/json;level=1' })
    end
end