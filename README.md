fixingVerify
============

Deploying the things a relying party needs to use to connect to verify on The
Government PaaS.

How this works
--------------

This repo contains a [Rakefile](https://github.com/ruby/rake) which sets up the following tasks (from `rake -T`):

```
rake clean                                                              # Remove downloaded files and build products
rake default                                                            # Push all the applications defined in config.yml
rake out/hacks                                                          # Create the hacks directory
rake out/hacks/passport-verify-stub-relying-party                       # Run the untar_passport_verify_stub_relying_party hack
rake out/hacks/passport-verify-stub-relying-party/package/package.json  # Run the bodge_node_version hack
rake out/hacks/verify-matching-service-adapter-custom-config.zip        # Run the add_custom_msa_config_and_truststore_to_zip hack
rake out/pki                                                            # Create the pki directory
rake out/releases                                                       # Create the releases directory
rake out/releases/passport-verify-stub-relying-party.tar.gz             # Download https://github.com/alphagov/passport-verify-stub-relying-party/releases/download/1.0.0/passport-verify-stub-relying-party-1.0.0.tgz
rake out/releases/verify-local-matching-service-example.zip             # Download https://github.com/alphagov/verify-local-matching-service-example/releases/download/0.0.1/verify-local-matching-service-example.zip
rake out/releases/verify-matching-service-adapter.zip                   # Download https://github.com/richardTowers/verify-matching-service-adapter/releases/download/HACK/verify-matching-service-adapter-3.1.0-unspecified.zip
rake out/releases/verify-service-provider.zip                           # Download https://github.com/alphagov/verify-service-provider/releases/download/1.0.0/verify-service-provider-1.0.0.zip
rake push                                                               # Push all the applications defined in config.yml
```

This downloads released artifacts produced by the Verify team, generates the
PKI they need to run, and uses `cf push` to deploy them to the PaaS.

There are a couple of hacky things that need doing at the moment that hopefully
the Verify team will help us address. For example:

* The MSA uses a non-standard java artefact that the java buildpack doesn't understand
  * We've hacked our way around this by building our own release
* The MSA doesn't ship with a config file that can be overridden with environment variables
  * We copied our own config file in to the zip before deploying
* The passport-verify-stub-relying-party release is a .tar.gz, which cloudfoudry can't handle
  * Unzipping it before deploying it fixes this, but it would be nicer as a .zip
* The current release of passport-verify-stub-relying-party only supports node 6.12
  * Overriding this in package.json before deploying

Next steps
----------

* Work with Verify to remove the hacks (in particular those for the MSA)
* Work out an internal use case?
* Deploy through a pipeline of some kind, add blue-green deployments
* Consider using a bespoke service instead of passport-verify-stub-relying-party
* Discuss with Verify's architects if they would allow a connection to production
* Add a route-service to restrict access to the MSA to just Verify's IP range as per [Verify's docs](https://alphagov.github.io/rp-onboarding-tech-docs/pages/matching/matchingserviceadapter.html#connect-your-matching-service-adapter-to-the-internet-securely)

