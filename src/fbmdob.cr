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
      data = @data.to_a
      new_data = [] of UInt8

      until data.empty?
        next_byte = data.shift

        if next_byte == 70
          new_data.push(next_byte)
          next_bytes = data.shift(3)

          if next_bytes == [66, 77, 68]
            new_data.concat(next_bytes)

            bom = data.shift(6)
            new_data.concat(bom)

            case bom
            when [48, 49, 48, 48, 48, 97]
              hex = data.shift(8 * 10)
              new_data.concat(hex.shuffle)
            when [50, 51, 48, 48, 48, 57]
              hex = data.shift(8 * 9)
              new_data.concat(hex.shuffle)
            end
          else
            new_data.concat(next_bytes)
          end
        else
          new_data.push(next_byte)
        end
      end

      @data = Slice.new(new_data.to_unsafe, new_data.size)
    end

    def to_b64
      Base64.encode(@data)
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
