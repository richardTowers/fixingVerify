require 'fileutils'
require_relative 'lib/config'
require_relative 'lib/helpers'
require_relative 'lib/pki'
require_relative 'lib/hacks'

Dir.chdir __dir__

desc 'Push all the applications defined in config.yml'
task default: [:push]

applications = load_applications_from_config

desc 'Push all the applications defined in config.yml'
task push: applications.map(&:path) + applications.flat_map(&:hacks).map(&:path) + applications.select(&:vars_file).map{|a|a.vars_file.path} do
  command =  'cf push --vars-file out/pki/msa-vars.yml --vars-file out/pki/vsp-vars.yml'
  puts command
  system command
end

desc 'Create the releases directory'
directory 'out/releases'

desc 'Create the pki directory'
directory 'out/pki'

desc 'Create the hacks directory'
directory 'out/hacks'

desc 'Remove downloaded files and build products'
task :clean do
  rm_rf 'out'
end

applications.each do |app|
  desc "Download #{app.url}"
  task app.path => 'out/releases' do
    unless File.exist?(app.path) && checksum_matches(app)
      puts app.path
      download_app(app)
    end
  end

  if app.vars_file
    vf = app.vars_file

    vf.items.each do |item|
      file item.key.path => 'out/pki' do
        create_private_key(item.key)
      end

      if item.certificate
        file item.certificate.path => ['out/pki', item.key.path] do
          create_certificate(item.certificate, item.key.path)
        end
      end
    end

    file vf.path => ['out/pki'] + vf.item_paths do
      File.open(vf.path, 'w') do |file|
        vf.items.each do |item|
          file.puts "#{item.key.variable}: '#{read_as_base64(item.key.path)}'"
          if item.certificate
            file.puts "#{item.certificate.variable}: '#{read_as_base64(item.certificate.path)}'"
          end
        end
      end
    end
  end

  if app.hacks
    hacker = Hacker.new
    app.hacks.each do |hack|
      desc "Run the #{hack.method} hack"
      task hack.path => ['out/hacks', app.path] do
        unless File.exist?(hack.path) && FileUtils.uptodate?(hack.path, [app.path])
          puts hack.path
          hacker.public_send(hack.method, app, hack)
        end
      end
    end
  end
end
