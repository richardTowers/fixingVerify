require 'base64'

def create_private_key(key)
  puts key.filename

  pem_path = key.path.sub(/\.pk8$/, '.pem')
  Dir.chdir("#{__dir__}/..") do
    `openssl genrsa -out '#{pem_path}' 2048`
    `openssl pkcs8 -topk8 -inform PEM -outform DER -in '#{pem_path}' -out '#{key.path}' -nocrypt`
  end
end

def create_certificate(certificate, private_key_path)
  puts certificate.filename

  pem_path = private_key_path.sub(/\.pk8$/, '.pem')
  Dir.chdir("#{__dir__}/..") do
    `openssl req -batch -new -subj '/CN=#{certificate.variable}' -key '#{pem_path}' | openssl x509 -req -sha256  -signkey '#{pem_path}' -out '#{certificate.path}'`
  end
end


def read_as_base64(path)
  Dir.chdir("#{__dir__}/..") do
    Base64.strict_encode64(IO.binread(path))
  end
end
