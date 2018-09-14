require 'json'
require 'fileutils'

class Hacker
  def add_custom_msa_config_and_truststore_to_zip(app, hack)
    Dir.chdir "#{__dir__}/.." do
      FileUtils.cp app.path, hack.path

      # Note: shelling out to `zip` instead of using rubyzip
      # to avoid venturing outside the ruby stdlib
      `zip #{hack.path} test_ida_metadata.ts verify-matching-service-adapter.yml`
    end
  end

  def untar_passport_verify_stub_relying_party(app, hack)
    FileUtils.mkdir hack.path unless Dir.exist? hack.path
    Dir.chdir hack.path do
      `tar -xzf #{__dir__}/../#{app.path}`
    end
  end

  def bodge_node_version(app, hack)
    package = JSON.parse(File.read(hack.path))
    package["engines"] = { node: '6.x' }
    File.open(hack.path, 'w') do |file|
      file.write(JSON.pretty_generate(package))
    end
  end
end

