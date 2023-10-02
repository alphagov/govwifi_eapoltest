# frozen_string_literal: true

require_relative "./eapoltest_client"

module Services
  def self.eapol_test
    EapoltestClient
  end
end
