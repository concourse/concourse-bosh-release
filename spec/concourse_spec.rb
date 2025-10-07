# frozen_string_literal: true

require 'erb'
require 'rspec'

# Define a test suite for the 'backup.sh.erb' template
RSpec.describe 'backup.sh.erb template' do
  def render_template(postgresql_version)
    template_path = File.expand_path('../jobs/bbr-atcdb/templates/backup.sh.erb', __dir__)
    template = ERB.new(File.read(template_path))

    # Simulate the BOSH `p()` helper to retrieve template properties
    def p(key)
      { 'postgresql.version' => @postgresql_version || '13' }[key]
    end
    @postgresql_version = postgresql_version
    template.result(binding)
  end

  # Test: when no version is specified, the default version should be 13
  it 'defaults to version 13 if no version is specified' do
    output = render_template(nil)
    expect(output).to include('PG_VERSION="13"')
  end
  # Test: when version 13 is passed, it should appear in the rendered script
  it 'injects the correct PostgreSQL version' do
    output = render_template('13')
    expect(output).to include('PG_VERSION="13"')
  end
  # Test: when version 15 is passed, it should appear in the rendered script
  it 'handles another version correctly' do
    output = render_template('15')
    expect(output).to include('PG_VERSION="15"')
  end
end