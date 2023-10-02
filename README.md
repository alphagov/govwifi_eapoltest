# GovwifiEapoltest

This Gem is used to test FreeRADIUS installations

## Usage

Initialize the test with\
```ruby
eapol_test = GovwifiEapoltest.new(radius_ips: ["10.0.0.1", "10.0.0.2"], 
                                  secret: "mysecret")
```

And then to run a PEAP MSCHAP test run:
```ruby
eapoltest.run_peap_mschapv2(server_cert_path: "/path/to/server/certificate.pem, 
                            username: "ABCDEF", 
                            password: "BearCatDuck",
                            tls_version: :tls1_2)
```

The output is an array with the contents of the output of the Eapol_test command run against each server.
                
## Matchers

The gem also provides a set of RSpec matchers to make facilitate testing.

```ruby
expect(output).to use_tls_version_1_0
expect(output).to use_tls_version_1_1
expect(output).to use_tls_version_1_2
expect(output).to use_tls_version_1_3
expect(output).to have_been_successful
expect(output).to have_failed
```

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
