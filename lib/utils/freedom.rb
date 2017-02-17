# -*- encoding: utf-8 -*-
module Utils
  class Freedom
    class << self
      def user_agent
        "Mozilla/5.0 (#{os})"\
        "AppleWebKit/#{webkit_version}"\
        '(KHTML, like Gecko)'\
        'Chrome/34.0.1847.116'\
        "Safari/#{safa_version}"
      end

      # 系统
      def os
        [
          'Windows NT 6.1; WOW64',
          "Macintosh; Intel Mac OS X #{mac_version}"
        ].sample
      end

      def ip
        "116.#{rand(200..233)}.#{rand(80..200)}.#{rand(200..255)}"
      end

      private

      def safa_version
        "#{rand(500..800)}.#{rand(100)}"
      end
      alias_method :webkit_version, :safa_version

      def mac_version
        "10_#{rand(12)}_#{rand(10)}"
      end
    end
  end
end
