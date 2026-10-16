# frozen_string_literal: true

require 'erb'
require 'ostruct'
require 'rspec'

class WorkerTemplateContext
  attr_accessor :spec, :properties

  def initialize(spec_id, properties = {})
    @spec = OpenStruct.new(id: spec_id)
    @properties = properties
  end

  def p(name, default = nil)
    @properties.fetch(name, default)
  end

  def if_p(*names)
    values = names.map { |name| @properties[name] }
    if values.all? { |v| !v.nil? }
      yield(*values)
    end
  end

  def if_link(_name)
    # no-op
  end

  def link(_name)
    OpenStruct.new(
      p: ->(_k) { 2222 },
      instances: [OpenStruct.new(address: '10.0.0.1')]
    )
  end

  def get_binding
    binding
  end
end

RSpec.describe 'worker templates' do
  describe 'env.sh.erb' do
    def render_template(properties = {})
      template_path = File.expand_path('../jobs/worker/templates/env.sh.erb', __dir__)
      template = ERB.new(File.read(template_path), trim_mode: '-')
      context = WorkerTemplateContext.new('worker-0', properties)
      template.result(context.get_binding)
    end

    it 'does not export CONCOURSE_P2P_STREAMING_GROUP when p2p_streaming_group is not set' do
      output = render_template
      expect(output).not_to include('CONCOURSE_P2P_STREAMING_GROUP')
    end

    it 'exports CONCOURSE_P2P_STREAMING_GROUP when p2p_streaming_group is set' do
      output = render_template('p2p_streaming_group' => 'group-a')
      expect(output).to include('export CONCOURSE_P2P_STREAMING_GROUP=group-a')
    end
  end

  describe 'env.ps1.erb' do
    def render_template(properties = {})
      template_path = File.expand_path('../jobs/worker-windows/templates/env.ps1.erb', __dir__)
      template = ERB.new(File.read(template_path), trim_mode: '-')
      context = WorkerTemplateContext.new('worker-windows-0', properties)
      template.result(context.get_binding)
    end

    it 'does not export CONCOURSE_P2P_STREAMING_GROUP when p2p_streaming_group is not set' do
      output = render_template('worker_gateway.hosts' => ['10.0.0.1:2222'])
      expect(output).not_to include('CONCOURSE_P2P_STREAMING_GROUP')
    end

    it 'exports CONCOURSE_P2P_STREAMING_GROUP when p2p_streaming_group is set' do
      output = render_template(
        'worker_gateway.hosts' => ['10.0.0.1:2222'],
        'p2p_streaming_group' => 'group-a'
      )
      expect(output).to include('$env:CONCOURSE_P2P_STREAMING_GROUP = "group-a"')
    end
  end
end
