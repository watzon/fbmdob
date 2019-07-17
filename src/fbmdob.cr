require "kemal"
require "base64"
require "zip"

module Fbmdob
  VERSION = "0.1.0"

  BMD = [66, 77, 68]
  LONG = [48, 49, 48, 48, 48, 97]
  SHORT = [50, 51, 48, 48, 48, 57]

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

          if next_bytes == BMD
            new_data.concat(next_bytes)

            bom = data.shift(6)
            new_data.concat(bom)

            case bom
            when LONG
              hex = data.shift(8 * 10)
              new_data.concat(hex.shuffle)
            when SHORT
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

INFO_TEXT = <<-TEXT
Thank you for using the Facebook Metadata Obfuscation Tool! I hope you had a good experience. Please share this tool with your friends and, if you feel so inclined, donate on my Patreon :) I provide these tools for free, but servers unfortunately aren't.

Patreon: https://www.patreon.com/watzon
Github: https://github.com/watzon
Twitter: https://twitter.com/_watzon
Keybase: https://keybase.com/watzon
TEXT

get "/" do
  render "src/views/index.ecr", "src/views/layouts/default.ecr"
end

post "/images" do |env|
  begin
    uploads = env.params.files
  rescue ex
    halt(env, 503, ex.message || "Something went wrong")
  end

  if !uploads || uploads.empty?
    pp uploads
    halt(env, 422, "Invalid request")
  end

  begin
    images = uploads.values.map do |upload|
      name = upload.filename
      image = upload.tempfile

      b64 = Base64.encode(image.gets_to_end)

      image = Fbmdob::Image.from_b64(b64)
      image.fuck_facebook

      { name: name, data: image.data }
    end

    tmp = File.tempname("fbmdob", ".zip")
    zip = File.open(tmp, "w") do |file|
      Zip::Writer.open(file) do |zip|

        images.each do |image|
          name = image[:name] || Random::Secure.hex(10) + ".jpg"
          zip.add(name) do |io|
            io << IO::Memory.new(image[:data])
          end
        end

        zip.add("info.txt", INFO_TEXT)
      end
    end

    File.basename(tmp, ".zip")
  rescue ex
    halt(env, 503, "Something went wrong")
  end
end

get "/download/:name" do |env|
  if name = env.params.url["name"]?
    begin
      name = "#{name}.zip"
      path = File.join(Dir.tempdir, name)
      send_file env, path
    rescue exception
      halt(env, 404, "Not found")
    end
  else
    halt(env, 404, "Not found")
  end
end

get "/ping" do
  "pong"
end

Kemal.run do |config|
  config.port = ENV["PORT"]? ? ENV["PORT"].to_i : 6969
end
