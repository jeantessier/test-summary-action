require './lib/report_generator'

describe ReportGenerator do
  subject(:generator) { described_class.new '' }

  let(:random) { Random.new }
  let(:out) { spy('out') }

  describe 'print_headers' do
    let(:first_header_line) { '| Subproject | Status | Tests | Passed | Skipped | Failures | Errors |' }
    let(:second_header_line) { '|------------|:------:|:-----:|:------:|:-------:|:--------:|:------:|' }

    before do
      generator.send(:print_headers, out)
    end

    it 'shows expected headers' do
      expect(out).to have_received(:puts).with(first_header_line).ordered
      expect(out).to have_received(:puts).with(second_header_line).ordered
    end
  end

  describe 'print_group' do
    let(:group) { 'some group' }

    before do
      generator.send(:print_group, out, group, counts)
    end

    context 'without failures or errors' do
      let(:counts) { described_class::COUNT_XPATHS.transform_values { 0 } }

      it 'shows zeroes' do
        expect(out).to have_received(:puts).with("| #{group} | :white_check_mark: | 0 | 0 | 0 | 0 | 0 |")
      end
    end

    context 'with failures and errors' do
      let(:counts) { described_class::COUNT_XPATHS.transform_values { random.rand 1..100 } }

      it 'shows error sign' do
        expect(out).to have_received(:puts).with("| #{group} | :x: | #{counts.values.join(' | ')} |")
      end
    end
  end

  describe 'count' do
    subject(:count) do
      generator.send(:count, docs, xpath)
    end

    let(:first_doc) { double('doc1') }
    let(:last_doc) { double('doc2') }
    let(:docs) { [first_doc, last_doc] }
    let(:count_for_first_doc) { random.rand 100.0 }
    let(:count_for_last_doc) { random.rand 100.0 }
    let(:total) { count_for_first_doc + count_for_last_doc }

    let(:xpath) { 'foo' }

    before do
      allow(first_doc).to receive(:xpath).with("count(//#{xpath})").and_return(count_for_first_doc)
      allow(last_doc).to receive(:xpath).with("count(//#{xpath})").and_return(count_for_last_doc)
    end

    it { is_expected.to eq(total.to_i) }
  end

  describe 'counts' do
    subject(:counts) do
      generator.send(:counts, docs)
    end

    let(:doc) { double('doc') }
    let(:docs) { [doc] }
    let(:tests) { random.rand 100.0 }
    let(:passed) { random.rand 100.0 }
    let(:skipped) { random.rand 100.0 }
    let(:failures) { random.rand 100.0 }
    let(:errors) { random.rand 100.0 }

    before do
      allow(doc).to receive(:xpath).with('count(//testcase)').and_return(tests)
      allow(doc).to receive(:xpath).with('count(//testcase[not(*)])').and_return(passed)
      allow(doc).to receive(:xpath).with('count(//testcase[skipped])').and_return(skipped)
      allow(doc).to receive(:xpath).with('count(//testcase[failure])').and_return(failures)
      allow(doc).to receive(:xpath).with('count(//testcase[error])').and_return(errors)
    end

    it 'converts all counts to integers' do
      expect(counts).to eq({
                             tests: tests.to_i,
                             passed: passed.to_i,
                             skipped: skipped.to_i,
                             failures: failures.to_i,
                             errors: errors.to_i,
                           })
    end
  end
end
