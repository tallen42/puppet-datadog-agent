require 'spec_helper'

describe 'datadog_agent::integrations::tcp_check' do
  ALL_SUPPORTED_AGENTS.each do |agent_major_version|
    context 'supported agents' do
      let(:pre_condition) { "class {'::datadog_agent': agent_major_version => #{agent_major_version}}" }
      let(:params) do
        {
          check_name: 'foo.bar.baz',
          host: 'foo.bar.baz',
          port: '80'
        }
      end

      conf_file = "#{CONF_DIR}/tcp_check.d/conf.yaml"

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file(conf_file).with(
          owner: DD_USER,
          group: DD_GROUP,
          mode: PERMISSIONS_PROTECTED_FILE,
        )
      }
      it { is_expected.to contain_file(conf_file).that_requires("Package[#{PACKAGE_NAME}]") }
      it { is_expected.to contain_file(conf_file).that_notifies("Service[#{SERVICE_NAME}]") }

      context 'with default parameters' do
        let(:params) do
          {
            check_name: 'foo.bar.baz',
            host: 'foo.bar.baz',
            port: '80'
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{name: }) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: }) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: }) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 10}) } # default value is 10
        it { is_expected.to contain_file(conf_file).without_content(%(threshold: )) }
        it { is_expected.to contain_file(conf_file).without_content(%r{window: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{collect_response_time: }) }
        it { is_expected.to contain_file(conf_file).without_content(%r{tags: }) }
      end

      context 'with parameters set' do
        let(:params) do
          {
            check_name: 'foo.bar.baz',
            host: 'foo.bar.baz',
            port: '80',
            timeout: 123,
            threshold: 456,
            window: 789,
            collect_response_time: true,
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{name: foo.bar.baz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{host: foo.bar.baz}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{port: 80}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 123}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{threshold: 456}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{window: 789}) }
        it { is_expected.to contain_file(conf_file).with_content(%r{collect_response_time: true}) }
      end

      context 'with tags parameter array' do
        let(:params) do
          {
            check_name: 'foo.bar.baz',
            host: 'foo.bar.baz',
            port: '80',
            tags: ['foo', 'bar', 'baz'],
          }
        end

        it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz\s*?[^-]}m) }
      end

      context 'with tags parameter empty values' do
        context 'mixed in with other tags' do
          let(:params) do
            {
              check_name: 'foo.bar.baz',
              host: 'foo.bar.baz',
              port: '80',
              tags: ['foo', '', 'baz'],
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- baz\s*?[^-]}m) }
        end

        context 'single element array of an empty string' do
          let(:params) do
            {
              tags: [''],
            }
          end

          skip('undefined behavior')
        end

        context 'single value empty string' do
          let(:params) do
            {
              tags: '',
            }
          end

          skip('doubly undefined behavior')
        end

        context 'with multiple instances' do
          let(:params) do
            {
              instances: [
                {
                  check_name: 'foo.bar.baz',
                  host: 'foo.bar.baz',
                  port: '80',
                  timeout: 123,
                  threshold: 456,
                  window: 789,
                  collect_response_time: true,
                },
                {
                  check_name: 'baz.bar.foo',
                  host: 'baz.bar.foo',
                  port: '8080',
                  timeout: 456,
                  tags: ['foo', 'bar', 'baz']
                },
              ]
            }
          end

          it { is_expected.to contain_file(conf_file).with_content(%r{name: foo.bar.baz}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{host: foo.bar.baz}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{port: 80}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 123}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{threshold: 456}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{window: 789}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{collect_response_time: true}) }

          it { is_expected.to contain_file(conf_file).with_content(%r{name: baz.bar.foo}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{host: baz.bar.foo}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{port: 8080}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{timeout: 456}) }
          it { is_expected.to contain_file(conf_file).with_content(%r{tags:\s+- foo\s+- bar\s+- baz\s*?[^-]}m) }
        end
      end
    end
  end
end
