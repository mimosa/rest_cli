# -*- encoding: utf-8 -*-
require 'rest_cli'

# http://face.g-secret.com/2016/12/10/79c9347d-ca23-413d-ae27-7a1bfa34ae07/face.jpg
class Facexx3 < RestCli
  def initialize
    super('https://www.faceplusplus.com.cn/api/official/demo/facepp/v3')
  end

  def get(url)
    data = detect(url)
    puts data
    if data.nil? || data[:faces].empty?
      data = {is_face: false}
    else # flatten
      data.merge!(data.delete(:faces)[0]) # 只获取最大的一张脸
      data.merge!(data.delete(:attributes))
      data[:face_id] = data.delete(:face_token)
    end
    data
  end

  def facesets
    raw = self.post('faceset/getfacesets')
    raw&.delete(:facesets)
  end

  # private

  def detect(url)
    params = {
      image_url: url,
      return_landmark: 1,
      return_attributes: 'gender,age'
    }

    self.post('detect', params)
  end

  def search(face_id, limit = 5)
    params = {
      face_token: face_id,
      faceset_token: '30e2d43d43c3ca4a78b86cee76226eea',
      return_result_count: limit
    }

    self.post('search', params)
  end
end
