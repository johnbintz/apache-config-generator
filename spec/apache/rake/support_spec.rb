require 'spec_helper'
require 'apache/rake/support'

describe Apache::Rake::Support do
  include Apache::Rake::Support

  let(:source) { '/source' }
  let(:destination) { '/destination/available' }
  let(:symlink) { '/destination/enabled' }

  describe 'config_paths!' do
    before {
      @config = {
        :source => 'cats',
        :destination => 'dogs',
        :symlink => 'cows'
      }
    }

    subject { config_paths!; @config }

    its([:source_path]) { should == File.expand_path('cats') }
    its([:destination_path]) { should == File.expand_path('dogs') }
    its([:symlink_path]) { should == File.expand_path('cows') }
  end

  describe 'symlink_configs!' do
    before {
      @config = {
        :source_path => source,
        :destination_path => destination,
        :symlink_path => symlink
      }
    }

    subject { symlink_configs! }

    context 'source does not exist' do
      before { File.expects(:directory?).with(destination).returns(false) }

      it { expect { subject }.to raise_error(Errno::ENOENT) }
    end

    context 'source does exist' do
      before {
        File.expects(:directory?).with(destination).returns(true)
        FileUtils.expects(:rm_rf).with(symlink)
        FileUtils.expects(:mkdir_p).with(symlink)
        Dir.expects(:[]).with(File.join(destination, '**/*')).returns(dir_return)
      }

      context 'with no configs' do
        let(:dir_return) { [] }

        before { FileUtils.expects(:ln_sf).never }

        it { subject }
      end

      context 'with one config' do
        let(:filename) { File.join(destination, 'dogs/cats') }
        let(:dir_return) { [ filename ] }

        before { File.expects(:file?).with(filename).returns(is_file_result) }

        context 'is a directory' do
          let(:is_file_result) { false }

          it { subject }
        end

        context 'is a file' do
          let(:is_file_result) { true }

          before { File.expects(:read).with(filename).returns(read_result) }

          context 'config should not be symlinked' do
            let(:read_result) { ['# disabled'] }

            before { FileUtils.expects(:ln_sf).never }

            it { subject }
          end

          context 'config should be symlinked' do
            let(:read_result) { ['# whatever'] }

            before {
              FileUtils.expects(:mkdir_p).with(File.join(symlink, 'dogs'))
              FileUtils.expects(:ln_sf).with(filename, filename.gsub(destination, symlink))
            }

            it { subject }
          end
        end
      end
    end
  end
end