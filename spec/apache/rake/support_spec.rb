require 'spec_helper'

describe Apache::Rake::Support do
  include Apache::Rake::Support

  let(:source) { '/source' }
  let(:destination) { '/destination/available' }

  describe 'config_paths!' do
    before {
      @config = {
        :source => 'cats',
        :destination => 'dogs'
      }
    }

    subject { config_paths!; @config }

    its([:source_path]) { should == File.expand_path('cats') }
    its([:destination_path]) { should == File.expand_path('dogs') }
  end
end
