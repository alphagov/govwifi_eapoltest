# frozen_string_literal: true

require "services"
require_relative "../lib/govwifi_eapoltest"

class FakeEapolTest
  attr_reader :config_file, :radius_ips, :secret

  def initialize
    @radius_ips = []
  end

  def run(config_file_path:, radius_ip:, secret:)
    @config_file = File.read(config_file_path)
    @radius_ips << radius_ip
    @secret = secret
  end
end

describe GovwifiEapoltest do
  let(:eapol_test) { GovwifiEapoltest.new(radius_ips:, secret:) }
  let(:fake_eapol_test) { FakeEapolTest.new }
  let(:radius_ips) { ["1.1.1.1", "2.2.2.2"] }
  let(:secret) { "secret" }
  let(:server_cert_path) { "/path/to/server_cert.pem" }
  before :each do
    allow(Services).to receive(:eapol_test).and_return(fake_eapol_test)
  end
  describe "#run_peap_mschapv2" do
    let(:username) { "user" }
    let(:password) { "pass" }
    it "passes a temporary config file with the correct parameters filled in" do
      eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:)
      expect(fake_eapol_test.config_file).to include('ssid="GovWifi"')
      expect(fake_eapol_test.config_file).to include('identity="user"')
      expect(fake_eapol_test.config_file).to include('password="pass"')
    end
    it "runs eapol_test twice, with both radius ips" do
      eapol_test.run_peap_mschapv2(server_cert_path:, username: "user", password:)
      expect(fake_eapol_test.radius_ips).to match_array(radius_ips)
    end
    it "runs eapol_test with the correct secret" do
      eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:)
      expect(fake_eapol_test.secret).to eq(secret)
    end
    it "returns the result of each eapol_test call" do
      allow(fake_eapol_test).to receive(:run).and_return("RESULT1", "RESULT2")
      result = eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:)
      expect(result).to eq(%w[RESULT1 RESULT2])
    end
    describe "TLS versions" do
      let(:tlsv1_0) { "tls_disable_tlsv1_0=1" }
      let(:tlsv1_1) { "tls_disable_tlsv1_1=1" }
      let(:tlsv1_2) { "tls_disable_tlsv1_2=1" }
      let(:tlsv1_3) { "tls_disable_tlsv1_3=1" }
      let(:phase1) { [tlsv1_0, tlsv1_1, tlsv1_2, tlsv1_3].join(" ") }

      describe "TLS version 1.0" do
        let(:tlsv1_0) { "tls_disable_tlsv1_0=0" }
        it "uses TLS version 1.0" do
          eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:, tls_version: :tls1_0)
          expect(fake_eapol_test.config_file).to include(phase1)
        end
      end
      describe "TLS version 1.1" do
        let(:tlsv1_1) { "tls_disable_tlsv1_1=0" }
        it "uses TLS version 1.1" do
          eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:, tls_version: :tls1_1)
          expect(fake_eapol_test.config_file).to include(phase1)
        end
      end
      describe "TLS version 1.2" do
        let(:tlsv1_2) { "tls_disable_tlsv1_2=0" }
        it "uses TLS version 1.2" do
          eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:, tls_version: :tls1_2)
          expect(fake_eapol_test.config_file).to include(phase1)
        end
      end
      describe "TLS version 1.3" do
        let(:tlsv1_3) { "tls_disable_tlsv1_3=0" }
        it "uses TLS version 1.3" do
          eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:, tls_version: :tls1_3)
          expect(fake_eapol_test.config_file).to include(phase1)
        end
      end
      describe "Unknown TLS version" do
        it "raises an error" do
          expect {
            eapol_test.run_peap_mschapv2(server_cert_path:, username:, password:, tls_version: :tls1_4)
          }.to raise_error("Unknown TLS version tls1_4")
        end
      end
    end
  end

  describe "#run_eap_tls" do
    let(:client_cert_path) { "/path/to/client_cert.pem" }
    let(:client_key_path) { "/path/to/client_key.pem" }
    it "passes a temporary config file with the correct parameters filled in" do
      eapol_test.run_eap_tls(server_cert_path:, client_cert_path:, client_key_path:)
      expect(fake_eapol_test.config_file).to include('ca_cert="/path/to/server_cert.pem"')
      expect(fake_eapol_test.config_file).to include('client_cert="/path/to/client_cert.pem"')
      expect(fake_eapol_test.config_file).to include('private_key="/path/to/client_key.pem"')
    end
    it "runs eapol_test twice, with both radius ips" do
      eapol_test.run_eap_tls(server_cert_path:, client_cert_path:, client_key_path:)
      expect(fake_eapol_test.radius_ips).to eq(["1.1.1.1", "2.2.2.2"])
    end
    it "runs eapol_test with the correct secret" do
      eapol_test.run_eap_tls(server_cert_path:, client_cert_path:, client_key_path:)
      expect(fake_eapol_test.secret).to eq("secret")
    end
    it "returns the status of each radius call" do
      allow(fake_eapol_test).to receive(:run).and_return("RESULT1", "RESULT2")
      result = eapol_test.run_eap_tls(server_cert_path:, client_cert_path:, client_key_path:)
      expect(result).to eq(%w[RESULT1 RESULT2])
    end
  end
end
