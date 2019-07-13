require "kemal"
require "base64"

module Fbmdob
  VERSION = "0.1.0"

  class Image

    getter :data

    def initialize(@data : Bytes)
    end

    def self.from_b64(b64_string : String)
      data = Base64.decode_string(b64_string).to_slice
      new(data)
    end

    def fuck_facebook
      result = scan_metadata
      if result
        swap_hex(result.size)
        return true
      end
      false
    end

    def to_b64
      Base64.encode(@data)
    end

    private def scan_metadata
      io = IO::Memory.new(@data)

      until io.empty?
        if fbmd = io.gets("FBMD")
          bom = io.gets(6).to_s
          case bom
          when "01000a"
            result = bom + io.gets(8 * 11).to_s
          when "230009"
            result = bom + io.gets(8 * 10).to_s
          else
            return nil
          end
        end

        break
      end

      result
    end

    private def swap_hex(length)
      new_hex = random_hex(length / 2)
      @data = String.new(@data).sub(/FBMD[a-f0-9]+/, "FBMD#{new_hex}").to_slice
      new_hex
    end

    private def random_hex(length)
      Random::Secure.hex(length)
    end
  end
end

post "/" do |env|
  img_data = env.params.files["image"]?

  if !img_data
    halt(env, 422, "Invalid request")
  end

  begin
    file = img_data.tempfile
    b64 = Base64.encode(file.gets_to_end)

    file = Fbmdob::Image.from_b64(b64)
    file.fuck_facebook
    file.to_b64
  rescue ex
    halt(env, 503, "Something went wrong")
  end
end

Kemal.run do |config|
  config.port = ENV["PORT"]? ? ENV["PORT"].to_i : 6969
end
