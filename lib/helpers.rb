require 'open-uri'
require 'digest'

def download_app(app)
  case io = open(app.url)
  when StringIO then File.open(app.path, 'w') { |f| f.write(io) }
  when Tempfile then FileUtils.mv(io.path, app.path)
  end
  raise "Fatal: downloaded file #{app.path} did not match expected checksum" unless checksum_matches(app)
end

def checksum_matches(app)
  app.checksum == Digest::SHA256.file(app.path).hexdigest
end


