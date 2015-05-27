#
#   Author: Rohith
#   Date: 2015-04-20 14:42:38 +0100 (Mon, 20 Apr 2015)
#
#  vim:ts=2:sw=2:et
#

module Ansible
  module Cache
    def cache(key, duration = 12000, &block)
      cached_filename = "#{key}.cached"
      if !File.exist?(cached_filename)
        # get the content
        content = yield
        # save the content
        save_cached_content(cached_filename, content)
      else
        cached = load_cached_content(cached_filename)
        # check the age


      end
    end

    private
    def save_cached_content(filename, content)
      meta = {
        'timestamp' => Time.now,
        'content'   => content,
      }
      File.open(filename, 'w') do |fd|
        fd.write(meta)
      end
    end

    def load_cached_content(filename)
      YAML.load(File.open(filename))
    end
  end
end
