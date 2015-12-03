require 'spec_helper'

describe 'kibana' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        context "kibana class without any parameters" do
          let(:params) {{ }}
          it { should create_class('kibana') }
          it { should compile.with_all_deps }
        end
      end
    end
  end
end
