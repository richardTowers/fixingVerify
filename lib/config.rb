require 'yaml'

class PrivateKey
  attr_reader :variable, :filename, :path
  def initialize(hash)
    @variable = hash.fetch('variable')
    @filename = hash.fetch('filename')
    @path     = "out/pki/#{@filename}"
  end
end

class Certificate
  attr_reader :variable, :filename, :path
  def initialize(hash)
    @variable = hash.fetch('variable')
    @filename = hash.fetch('filename')
    @path     = "out/pki/#{@filename}"
  end
end

class VarsFileItem
  attr_reader :key, :certificate, :paths
  def initialize(hash)
    @key         = PrivateKey.new hash.fetch('key')
    @certificate = Certificate.new hash['certificate'] if hash.key? 'certificate'
    @paths       = [@key.path] + (@certificate ? [@certificate.path] : [])
  end
end

class VarsFile
  attr_reader :filename, :items, :path, :item_paths
  def initialize(hash)
    @filename = hash.fetch('filename')
    @items = hash.fetch('items', []).map{|item| VarsFileItem.new item}
    @item_paths = @items.flat_map {|item| item.paths}
    @path = "out/pki/#{@filename}"
  end
end

class Hack
  attr_reader :method, :filename, :path
  def initialize(hash)
    @method = hash.fetch('method')
    @filename = hash.fetch('filename')
    @path = "out/hacks/#{@filename}"
  end
end

class Application
  attr_reader :name, :url, :filename, :checksum, :path, :pki, :vars_file, :hacks

  def initialize(hash)
    @name      = hash.fetch('name')
    @url       = hash.fetch('url')
    @filename  = hash.fetch('filename')
    @checksum  = hash.fetch('checksum')
    @path      = "out/releases/#{@filename}"
    @vars_file = VarsFile.new(hash['vars_file']) if hash.key?('vars_file')
    @hacks     = hash.fetch('hacks', []).map{|hack| Hack.new hack}
  end
end

def load_applications_from_config()
  config = YAML.load_file("#{__dir__}/../config.yml")

  config
    .fetch('applications', [])
    .map {|app| Application.new(app)}
end

