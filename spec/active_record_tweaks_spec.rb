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

    describe '#cache_key_from_attribute' do
      before { Timecop.freeze }
      after { Timecop.return }

      let!(:record) { Parent.create! }

      before do
        record.class.class_eval do
          def virtual_update_at_1
            1.day.from_now
          end

          def virtual_update_at_2
            1.week.from_now
          end
        end
      end
      after do
        record.class.class_eval do
          remove_method :virtual_update_at_1

          remove_method :virtual_update_at_2
        end
      end

      let(:virtual_update_at_1) { record.virtual_update_at_1 }
      let(:virtual_update_at_1_in_cache_key) { virtual_update_at_1.utc.to_s(:nsec) }
      let(:virtual_update_at_2) { record.virtual_update_at_2 }
      let(:virtual_update_at_2_in_cache_key) { virtual_update_at_2.utc.to_s(:nsec) }

      subject { record.cache_key_from_attribute(*arguments) }

      context 'when called with no argument' do
        let(:arguments) { [] }

        specify { expect{subject}.to raise_error(ArgumentError) }
      end
      context 'when called with 1 attribute name' do
        let(:arguments) { [:virtual_update_at_1] }

        it {should match /#{described_class.model_name.cache_key}\/#{record.id}\-#{virtual_update_at_1_in_cache_key}/}
      end
      context 'when called with 2 attribute names' do
        let(:arguments) { [:virtual_update_at_1, :virtual_update_at_2] }

        context 'and virtual_update_at_1 < virtual_update_at_2' do
          before do
            record.class.class_eval do
              def virtual_update_at_2
                virtual_update_at_1 + 1.day
              end
            end
          end

          it {should match /#{described_class.model_name.cache_key}\/#{record.id}\-#{virtual_update_at_2_in_cache_key}/}
        end

        context 'and virtual_update_at_1 > virtual_update_at_2' do
          before do
            record.class.class_eval do
              def virtual_update_at_2
                virtual_update_at_1 - 1.day
              end
            end
          end

          it {should match /#{described_class.model_name.cache_key}\/#{record.id}\-#{virtual_update_at_1_in_cache_key}/}
        end

        context 'and virtual_update_at_1 is nil' do
          before do
            record.class.class_eval do
              def virtual_update_at_1
                nil
              end
            end
          end

          it {should match /#{described_class.model_name.cache_key}\/#{record.id}\-#{virtual_update_at_2_in_cache_key}/}
        end
        context 'and virtual_update_at_2 is nil' do
          before do
            record.class.class_eval do
              def virtual_update_at_2
                nil
              end
            end
          end

          it {should match /#{described_class.model_name.cache_key}\/#{record.id}\-#{virtual_update_at_1_in_cache_key}/}
        end
      end
    end


    describe '.cache_key' do
      subject { klass.cache_key }

      context 'when a class has no update_at column' do
        let(:klass) { Stone }

        context 'and has no record' do
          before { klass.count.should eq 0 }

          it { should match /\/#{klass.count}$/ }
        end
        context 'and has a record' do
          before { klass.create! }

          it { should match /\/#{klass.count}$/ }
        end
      end

      context 'when a class has updated_at column' do
        let(:klass) { Parent }

        context 'and has no record' do
          before { klass.count.should eq 0 }

          it { should match /\/#{klass.count}$/ }
        end

        context 'and has a record' do
          let!(:parent) { klass.create! }

          it { should eq "parents/all/#{klass.count}-#{klass.maximum(:updated_at).utc.to_s(:nsec)}" }

          context 'when record all has nil updated timestamps' do
            before { klass.update_all(updated_at: nil) }

            it { should match /\/#{klass.count}$/ }
          end

          describe 'precision' do
            let!(:child) { Child.create!(parent: parent) }
            let!(:old_cache_key) { klass.cache_key }
            let(:new_cache_key) { klass.cache_key }

            subject { new_cache_key }

            context 'when self touched' do
              before { parent.touch }

              it { should_not eq old_cache_key }
            end

            context 'when child touched' do
              before { child.touch }

              it { should_not eq old_cache_key }
            end
          end
        end
      end

      context 'when a class has updated_at AND updated_on column' do
        let(:klass) { Person }

        context 'when getting cache_key using update_on column' do
          subject { klass.cache_key(:updated_on) }

          context 'and has no record' do
            before { klass.count.should eq 0 }

            it { should match /\/#{klass.count}$/ }
          end
          context 'and has a record' do
            let!(:person) { klass.create! }

            context 'and it has updated_at value only' do
              before { person.update_attributes!(updated_at: Time.now, updated_on: nil) }

              it { should eq "people/all/#{klass.count}" }
            end

            context 'and it has updated_on value only' do
              before { person.update_attributes!(updated_at: nil, updated_on: Time.now) }

              it { should eq "people/all/#{klass.count}-#{klass.maximum(:updated_on).utc.to_s(:nsec)}" }
            end
          end
        end

        context 'when getting cache_key using both columns' do
          subject { klass.cache_key(:updated_at, :updated_on) }

          context 'and has no record' do
            before { klass.count.should eq 0 }

            it { should match /\/#{klass.count}$/ }
          end
          context 'and has a record' do
            let!(:person) { klass.create! }

            context 'and it has updated_on value only' do
              before { person.update_attributes!(updated_at: nil, updated_on: Time.now) }

              it { should eq "people/all/#{klass.count}-#{klass.maximum(:updated_on).utc.to_s(:nsec)}" }
            end

            context 'and it has newer updated_at' do
              before { person.update_attributes!(updated_at: Time.now + 3600, updated_on: Time.now) }

              it { should eq "people/all/#{klass.count}-#{klass.maximum(:updated_at).utc.to_s(:nsec)}" }
            end

            context 'and it has newer updated_on' do
              before { person.update_attributes!(updated_at: Time.now , updated_on: Time.now+ 3600) }

              it { should eq "people/all/#{klass.count}-#{klass.maximum(:updated_on).utc.to_s(:nsec)}" }
            end
          end
        end

        context 'when getting cache_key with nil' do
          subject { klass.cache_key(nil) }

          context 'and has no record' do
            before { klass.count.should eq 0 }

            it { should match /\/#{klass.count}$/ }
          end
          context 'and has a record' do
            let!(:person) { klass.create! }

            context 'and it has updated_on value only' do
              before { person.update_attributes!(updated_at: nil, updated_on: Time.now) }

              it { should eq "people/all/#{klass.count}" }
            end

            context 'and it has newer updated_at' do
              before { person.update_attributes!(updated_at: Time.now + 3600, updated_on: Time.now) }

              it { should eq "people/all/#{klass.count}" }
            end

            context 'and it has newer updated_on' do
              before { person.update_attributes!(updated_at: Time.now , updated_on: Time.now+ 3600) }

              it { should eq "people/all/#{klass.count}" }
            end
          end
        end
      end

      context 'when a class has custom timestamp format' do
        let(:klass) { Animal }
        let!(:record) { klass.create! }

        it { should eq "animals/all/#{klass.count}-#{klass.maximum(:updated_at).utc.to_s(:number)}" }
      end
    end
  end
end
