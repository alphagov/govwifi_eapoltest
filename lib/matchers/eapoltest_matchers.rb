# frozen_string_literal: true

RSpec::Matchers.define :use_tls_version_1_0 do
  match do |output|
    !output.include?("SSL: Using TLS version TLSv1.") && output.include?("SSL: Using TLS version TLSv1")
  end
end

RSpec::Matchers.define :use_tls_version_1_1 do
  match do |output|
    output.include?("SSL: Using TLS version TLSv1.1")
  end
end

RSpec::Matchers.define :use_tls_version_1_2 do
  match do |output|
    output.include?("SSL: Using TLS version TLSv1.2")
  end
end

RSpec::Matchers.define :use_tls_version_1_3 do
  match do |output|
    output.include?("SSL: Using TLS version TLSv1.3")
  end
end

RSpec::Matchers.define :have_been_successful do
  match do |output|
    output.split("\n").last == "SUCCESS"
  end
end

RSpec::Matchers.define :have_failed do
  match do |output|
    output.split("\n").last == "FAILURE"
  end
end
