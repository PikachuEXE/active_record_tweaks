require 'spec_helper'

describe Parent do
  describe 'included modules' do
    it do
      described_class.ancestors.should include(ActiveRecordTweaks)
    end
  end

  describe '::Integration' do
    describe '#cache_key_without_timestamp' do
      subject { record.cache_key_without_timestamp }


      context 'when record is a new record' do
        let(:record) { Parent.new }

        it 'works like #cache_key' do
          should eq "#{record.class.model_name.cache_key}/new"
        end
      end

      context 'when record is an existing record' do
        let(:record) { Parent.create! }


        context 'and update_at is nil' do
          before { record.update_attributes!(updated_at: nil) }

          it 'works like #cache_key' do
            should eq "#{record.class.model_name.cache_key}/#{record.id}"
          end
        end

        context 'and update_at is present' do
          it 'works like #cache_key when updated_at is nil' do
            should eq "#{record.class.model_name.cache_key}/#{record.id}"
          end
        end
      end

      context 'when record has no update_at column' do
        let!(:record) { Stone.create }

        it 'works like #cache_key when updated_at is nil' do
          should eq "#{record.class.model_name.cache_key}/#{record.id}"
        end
      end
    end
  end
end
