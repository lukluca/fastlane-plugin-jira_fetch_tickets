lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/jira_fetch_tickets/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-jira_fetch_tickets'
  spec.version       = Fastlane::JiraFetchTickets::VERSION
  spec.author        = 'Luca Tagliabue'
  spec.email         = 'homobonus-luca@hotmail.it'

  spec.summary       = 'Fetch ticekts on jira project using jql query'
  spec.homepage      = "https://github.com/lukluca/fastlane-plugin-jira_fetch_tickets"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'
end
