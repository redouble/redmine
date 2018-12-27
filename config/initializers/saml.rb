Redmine::OmniAuthSAML::Base.configure do |config|
  config.saml = {
    :assertion_consumer_service_url => "http://localhost:4000/auth/saml/callback", # OmniAuth callback URL
    :issuer                         => "http://localhost:4000/saml/metadata",      # The issuer name / entity ID. Must be an URI as per SAML 2.0 spec.
    :single_logout_service_url      => "http://localhost:4000/auth/saml/sls",      # The SLS (logout) callback URL
    :idp_sso_target_url             => "http://localhost:3000/saml/sso", # SSO login endpoint
    :idp_cert_fingerprint           => "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D", # SSO ssl certificate fingerprint
    # Alternatively, specify the full certifiate:
    # :idp_cert                       => "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----",
    # :name_identifier_format         => "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
    :name_identifier_format         => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
    :signout_url                    => "http://localhost:3000/saml/logout", # Optional signout URL, not supported by all identity providers
    :idp_slo_target_url             => "http://localhost:3000/saml/logout",
    :name_identifier_value          => "mail", # Which redmine field is used as name_identifier_value for SAML logout
    :attribute_mapping              => {
    # How will we map attributes from SSO to redmine attributes
      :login      => 'extra.raw_info.username',
      :mail       => 'extra.raw_info.email',
      :firstname  => 'extra.raw_info.firstname',
      :lastname   => 'extra.raw_info.lastname'
    }
  }

  config.on_login do |omniauth_hash, user|
    # Implement any hook you want here
  end
end
