require 'base64'
require 'json'
require 'net/http'
require 'net/https'

compliance_tool_init_url_slug  = 'service-test-data'
compliance_tool_init_domain    = 'compliance-tool-reference.ida.digital.cabinet-office.gov.uk'
service_entity_id              = 'http://verify-service-provider-0'
assertion_consumer_service_url = 'https://passport-verify-stub-relying-party-0.cloudapps.digital/verify/response'
matching_service_entity_id     = "https://verify-matching-service-adapter-0"
matching_service_signing_key   = Base64.encode64(File.read("#{__dir__}/../out/pki/msa-primary-saml-signing-key.pk8"))

def read_cert(path)
  File.readlines(path).select{|line|!line.include? '-----'}.join('').gsub("\n", '')
end

req = Net::HTTP::Post.new("/#{compliance_tool_init_url_slug}", {'Content-Type' =>'application/json'})
req.body = JSON.dump(
  serviceEntityId: service_entity_id,
  assertionConsumerServiceUrl: assertion_consumer_service_url,
  signingCertificate: read_cert("#{__dir__}/../out/pki/vsp-saml-signing-cert.pem"),
  encryptionCertificate: read_cert("#{__dir__}/../out/pki/vsp-saml-encryption-cert.pem"),
  expectedPID: 'TODO-dont-hardcode-pid',
  matchingServiceEntityId: matching_service_entity_id,
  matchingServiceSigningPrivateKey: matching_service_signing_key,
  useSimpleProfile:  false,
  userAccountCreationAttributes: [
    'FIRST_NAME',
    'FIRST_NAME_VERIFIED',
    'MIDDLE_NAME',
    'MIDDLE_NAME_VERIFIED',
    'SURNAME',
    'SURNAME_VERIFIED',
    'DATE_OF_BIRTH',
    'DATE_OF_BIRTH_VERIFIED',
    'CURRENT_ADDRESS',
    'CURRENT_ADDRESS_VERIFIED',
    'ADDRESS_HISTORY',
    'CYCLE_3'
  ]
)
req['Content-Type'] = 'application/json'

http = Net::HTTP.new(compliance_tool_init_domain, 443)
http.use_ssl = true
response = http.start {|http| http.request(req) }
puts response.body.inspect

