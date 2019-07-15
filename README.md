# Facebook Metadata Obfuscator

It [came to my attention recently](https://twitter.com/oasace/status/1149181539000864769) that Facebook is embedding tracking metadata in photos that you download from facebook.com using a IPTC special instruction that starts with `FBMD`. This is just one more way for Facebook to keep track of your activities on the internet, and a sneaky one at that.

This is a small server that uses Crystal and Kemal to swap the hash in that special instruction with a randomly generated one. Why not just remove the instruction completely you ask? Because, removing the instruction does nothing to Facebook. They just lose one of millions of tracked images. But replacing the hash with a new one may just fuck with their algorithm :wink:

## Installation

**Note:** You will need [crystal](https://crystal-lang.org) to build and run this. 

If you want to run this on your own server you'll need to clone this repo and build the server.

```bash
shards build
./bin/fbmdob
# => Kemal is ready to lead at http://0.0.0.0:6969
```

## Usage

Visit `localhost:6969` and follow the instructions on the page. Alternatively you can use CURL as follows:

```bash
curl localhost:6969/images -F 'image=@/path/to/image.jpg' -F 'image2=@/path/to/another.jpg'
# => fbmdob-20190714-27926-o9mzow
```

Copy the returned id and go to `locahost:6969/download/ID` to download the zip.

You can replace `localhost:6969` with `fbmdob.watzon.tech` to use my instance. Please be kind to my little vps!

## Development

If you want to contribute feel free to open a PR :smile:

## Contributing

1. Fork it (<https://github.com/your-github-user/fbmdob/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris](https://github.com/your-github-user) - creator and maintainer
