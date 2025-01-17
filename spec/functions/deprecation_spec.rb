# frozen_string_literal: true

require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'deprecation' do
    before(:each) do
      # this is to reset the strict variable to default
      Puppet.settings[:strict] = :warning
    end

    after(:each) do
      # this is to reset the strict variable to default
      Puppet.settings[:strict] = :warning
    end

    it { is_expected.not_to be_nil }
    it { is_expected.to run.with_params.and_raise_error(ArgumentError) }

    it 'displays a single warning' do
      if Puppet::Util::Package.versioncmp(Puppet.version, '5.0.0') >= 0 && Puppet::Util::Package.versioncmp(Puppet.version, '5.5.7') < 0
        expect(Puppet).to receive(:deprecation_warning).with('heelo at :', 'key')
        expect(Puppet).to receive(:deprecation_warning).with("Modifying 'autosign' as a setting is deprecated.")
      else
        expect(Puppet).to receive(:warning).with(include('heelo')).once
      end
      expect(subject).to run.with_params('key', 'heelo')
    end

    it 'displays a single warning, despite multiple calls' do
      if Puppet::Util::Package.versioncmp(Puppet.version, '5.0.0') >= 0 && Puppet::Util::Package.versioncmp(Puppet.version, '5.5.7') < 0
        expect(Puppet).to receive(:deprecation_warning).with('heelo at :', 'key').twice
        expect(Puppet).to receive(:deprecation_warning).with("Modifying 'autosign' as a setting is deprecated.")
      else
        expect(Puppet).to receive(:warning).with(include('heelo')).once
      end
      2.times do |_i|
        expect(subject).to run.with_params('key', 'heelo')
      end
    end

    it 'fails twice with message, with multiple calls. when strict= :error' do
      Puppet.settings[:strict] = :error
      expect(Puppet).not_to receive(:warning).with(include('heelo'))
      2.times do |_i|
        expect(subject).to run.with_params('key', 'heelo').and_raise_error(RuntimeError, %r{deprecation. key. heelo})
      end
    end

    it 'displays nothing, despite multiple calls. strict= :off' do
      Puppet.settings[:strict] = :off
      expect(Puppet).not_to receive(:warning).with(include('heelo'))
      2.times do |_i|
        expect(subject).to run.with_params('key', 'heelo')
      end
    end
  end
elsif Puppet.version.to_f < 4.0
  # Puppet version < 4 will use these tests.
  describe 'deprecation' do
    after(:each) do
      ENV.delete('STDLIB_LOG_DEPRECATIONS')
    end

    before(:each) do
      ENV['STDLIB_LOG_DEPRECATIONS'] = 'true'
    end

    it { is_expected.not_to be_nil }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }

    it 'displays a single warning' do
      expect(scope).to receive(:warning).with(include('heelo'))
      expect(subject).to run.with_params('key', 'heelo')
    end
  end
end
