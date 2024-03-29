require "spec_helper"

describe Parent do
  describe "included modules" do
    specify do
      expect(described_class.ancestors).to include(ActiveRecordTweaks)
    end
  end

  describe "::Integration" do
    describe "#cache_key_without_timestamp" do
      subject { record.cache_key_without_timestamp }

      context "when record is a new record" do
        let(:record) { Parent.new }

        it "works like #cache_key" do
          should eq "#{record.class.model_name.cache_key}/new"
        end
      end

      context "when record is an existing record" do
        let(:record) { Parent.create! }

        context "and update_at is nil" do
          before { record.update!(updated_at: nil) }

          it "works like #cache_key" do
            should eq "#{record.class.model_name.cache_key}/#{record.id}"
          end
        end

        context "and update_at is present" do
          it "works like #cache_key when updated_at is nil" do
            should eq "#{record.class.model_name.cache_key}/#{record.id}"
          end
        end
      end

      context "when record has no update_at column" do
        let!(:record) { Stone.create }

        it "works like #cache_key when updated_at is nil" do
          should eq "#{record.class.model_name.cache_key}/#{record.id}"
        end
      end
    end

    describe "#cache_key_from_attribute" do
      before { Timecop.freeze }
      after { Timecop.return }

      let!(:record) { Parent.create! }

      before do
        allow(record).to receive(:virtual_update_at_1) { 1.day.from_now }
        allow(record).to receive(:virtual_update_at_2) { 1.week.from_now }
      end

      let(:virtual_update_at_1) { record.virtual_update_at_1 }
      let(:virtual_update_at_1_in_cache_key) do

        virtual_update_at_1.utc.yield_self do |utc_time|
          if utc_time.respond_to?(:to_fs)
            utc_time.to_fs(:nsec)
          else
            utc_time.to_s(:nsec)
          end
        end
      end
      let(:virtual_update_at_2) { record.virtual_update_at_2 }
      let(:virtual_update_at_2_in_cache_key) do
        virtual_update_at_2.utc.yield_self do |utc_time|
          if utc_time.respond_to?(:to_fs)
            utc_time.to_fs(:nsec)
          else
            utc_time.to_s(:nsec)
          end
        end
      end

      subject { record.cache_key_from_attribute(*arguments) }

      context "when called with no argument" do
        let(:arguments) { [] }

        specify { expect { subject }.to raise_error(ArgumentError) }
      end
      context "when called with 1 attribute name" do
        let(:arguments) { [:virtual_update_at_1] }

        context "when and it's present" do
          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              \-
              #{virtual_update_at_1_in_cache_key}
              |x
          end
        end

        context "when and it's nil" do
          before do
            allow(record).to receive(:virtual_update_at_1) { nil }
          end

          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              |x
          end
        end
      end
      context "when called with 2 attribute names" do
        let(:arguments) { [:virtual_update_at_1, :virtual_update_at_2] }

        context "and #virtual_update_at_1 < #virtual_update_at_2" do
          before do
            allow(record).to receive(:virtual_update_at_2) { virtual_update_at_1 + 1.day }
          end

          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              \-
              #{virtual_update_at_2_in_cache_key}
              |x
          end
        end

        context "and #virtual_update_at_1 > #virtual_update_at_2" do
          before do
            allow(record).to receive(:virtual_update_at_2) { virtual_update_at_1 - 1.day }
          end

          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              \-
              #{virtual_update_at_1_in_cache_key}
              |x
          end
        end

        context "and #virtual_update_at_1 is nil" do
          before do
            allow(record).to receive(:virtual_update_at_1) { nil }
          end

          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              \-
              #{virtual_update_at_2_in_cache_key}
              |x
          end
        end
        context "and #virtual_update_at_2 is nil" do
          before do
            allow(record).to receive(:virtual_update_at_2) { nil }
          end

          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              \-
              #{virtual_update_at_1_in_cache_key}
              |x
          end
        end
        context "and both are nil" do
          before do
            allow(record).to receive(:virtual_update_at_1) { nil }
            allow(record).to receive(:virtual_update_at_2) { nil }
          end

          it do
            should match %r|
              #{described_class.model_name.cache_key}
              \/
              #{record.id}
              |x
          end
        end
      end
    end

    describe ".cache_key" do
      subject { klass.cache_key }

      context "when a class has no update_at column" do
        let(:klass) { Stone }

        context "and has no record" do
          before { expect(klass.count).to eq 0 }

          it { should match %r|\/#{klass.count}$| }
        end
        context "and has a record" do
          before { klass.create! }

          it { should match %r|\/#{klass.count}$| }
        end
      end

      context "when a class has updated_at column" do
        let(:klass) { Parent }

        context "and has no record" do
          before { expect(klass.count).to eq 0 }

          it { should match %r|\/#{klass.count}$| }
        end

        context "and has a record" do
          let!(:parent) { klass.create! }

          it do
            expected_time_str = klass.maximum(:updated_at).utc.yield_self do |utc_time|
              if utc_time.respond_to?(:to_fs)
                utc_time.to_fs(:nsec)
              else
                utc_time.to_s(:nsec)
              end
            end

            should eq "parents/all/"\
              "#{klass.count}-#{expected_time_str}"
          end

          context "when record all has nil updated timestamps" do
            before { klass.update_all(updated_at: nil) }

            it { should match %r|\/#{klass.count}$| }
          end

          describe "precision" do
            let!(:child) { Child.create!(parent: parent) }
            let!(:old_cache_key) { klass.cache_key }
            let(:new_cache_key) { klass.cache_key }

            subject { new_cache_key }

            context "when self touched" do
              before { parent.touch }

              it { should_not eq old_cache_key }
            end

            context "when child touched" do
              before { child.touch }

              it { should_not eq old_cache_key }
            end
          end
        end
      end

      context "when a class has updated_at AND updated_on column" do
        let(:klass) { Person }

        context "when getting cache_key using update_on column" do
          subject { klass.cache_key(:updated_on) }

          context "and has no record" do
            before { expect(klass.count).to eq 0 }

            it { should match %r|\/#{klass.count}$| }
          end
          context "and has a record" do
            let!(:person) { klass.create! }

            context "and it has updated_at value only" do
              before { person.update!(updated_at: Time.now, updated_on: nil) }

              it { should eq "people/all/#{klass.count}" }
            end

            context "and it has updated_on value only" do
              before { person.update!(updated_at: nil, updated_on: Time.now) }

              it do
                expected_time_str = klass.maximum(:updated_on).utc.yield_self do |utc_time|
                  if utc_time.respond_to?(:to_fs)
                    utc_time.to_fs(:nsec)
                  else
                    utc_time.to_s(:nsec)
                  end
                end

                should eq "people/all/"\
                  "#{klass.count}-#{expected_time_str}"
              end
            end
          end
        end

        context "when getting cache_key using both columns" do
          subject { klass.cache_key(:updated_at, :updated_on) }

          context "and has no record" do
            before { expect(klass.count).to eq 0 }

            it { should match %r|\/#{klass.count}$| }
          end
          context "and has a record" do
            let!(:person) { klass.create! }

            context "and it has updated_on value only" do
              before do
                person.update!(
                  updated_at: nil,
                  updated_on: Time.now,
                )
              end

              it do
                expected_time_str = klass.maximum(:updated_on).utc.yield_self do |utc_time|
                  if utc_time.respond_to?(:to_fs)
                    utc_time.to_fs(:nsec)
                  else
                    utc_time.to_s(:nsec)
                  end
                end

                should eq "people/all/"\
                  "#{klass.count}-#{expected_time_str}"
              end
            end

            context "and it has newer updated_at" do
              before do
                person.update!(
                  updated_at: Time.now + 3600,
                  updated_on: Time.now,
                )
              end

              it do
                expected_time_str = klass.maximum(:updated_at).utc.yield_self do |utc_time|
                  if utc_time.respond_to?(:to_fs)
                    utc_time.to_fs(:nsec)
                  else
                    utc_time.to_s(:nsec)
                  end
                end

                should eq "people/all/"\
                  "#{klass.count}-#{expected_time_str}"
              end
            end

            context "and it has newer updated_on" do
              before do
                person.update!(
                  updated_at: Time.now,
                  updated_on: Time.now + 3600,
                )
              end

              it do
                expected_time_str = klass.maximum(:updated_on).utc.yield_self do |utc_time|
                  if utc_time.respond_to?(:to_fs)
                    utc_time.to_fs(:nsec)
                  else
                    utc_time.to_s(:nsec)
                  end
                end

                should eq "people/all/"\
                  "#{klass.count}-#{expected_time_str}"
              end
            end
          end
        end

        context "when getting cache_key with nil" do
          subject { klass.cache_key(nil) }

          context "and has no record" do
            before { expect(klass.count).to eq 0 }

            it { should match %r|\/#{klass.count}$| }
          end
          context "and has a record" do
            let!(:person) { klass.create! }

            context "and it has updated_on value only" do
              before do
                person.update!(
                  updated_at: nil,
                  updated_on: Time.now,
                )
              end

              it { should eq "people/all/#{klass.count}" }
            end

            context "and it has newer updated_at" do
              before do
                person.update!(
                  updated_at: Time.now + 3600,
                  updated_on: Time.now,
                )
              end

              it { should eq "people/all/#{klass.count}" }
            end

            context "and it has newer updated_on" do
              before do
                person.update!(
                  updated_at: Time.now,
                  updated_on: Time.now + 3600,
                )
              end

              it { should eq "people/all/#{klass.count}" }
            end
          end
        end
      end

      context "when a class has custom timestamp format" do
        let(:klass) { Animal }
        let!(:record) { klass.create! }

        it do
          expected_time_str = klass.maximum(:updated_at).utc.yield_self do |utc_time|
            if utc_time.respond_to?(:to_fs)
              utc_time.to_fs(:number)
            else
              utc_time.to_s(:number)
            end
          end

          should eq "animals/all/"\
            "#{klass.count}-#{expected_time_str}"
        end
      end
    end

    describe ".cache_key_without_timestamp" do
      subject { klass.cache_key_without_timestamp }

      context "when a class has no update_at column" do
        let(:klass) { Stone }

        context "and has no record" do
          before { expect(klass.count).to eq 0 }

          it { should match %r|\/#{klass.count}$| }
        end
        context "and has a record" do
          before { klass.create! }

          it { should match %r|\/#{klass.count}$| }
        end
      end

      context "when a class has updated_at column" do
        let(:klass) { Parent }

        context "and has no record" do
          before { expect(klass.count).to eq 0 }

          it { should match %r|\/#{klass.count}$| }
        end

        context "and has a record" do
          let!(:parent) { klass.create! }

          it { should eq "parents/all/#{klass.count}" }

          context "when record all has nil updated timestamps" do
            before { klass.update_all(updated_at: nil) }

            it { should match %r|\/#{klass.count}$| }
          end
        end
      end

      context "when a class has updated_at AND updated_on column" do
        let(:klass) { Person }

        context "and has no record" do
          before { expect(klass.count).to eq 0 }

          it { should match %r|\/#{klass.count}$| }
        end
        context "and has a record" do
          let!(:person) { klass.create! }

          context "and it has updated_at value only" do
            before { person.update!(updated_at: Time.now, updated_on: nil) }

            it { should eq "people/all/#{klass.count}" }
          end

          context "and it has updated_on value only" do
            before { person.update!(updated_at: nil, updated_on: Time.now) }

            it { should eq "people/all/#{klass.count}" }
          end
        end
      end
    end
  end
end
