require 'nokogiri'

class ReportGenerator
  attr_reader :path_prefix

  def initialize(path_prefix)
    @path_prefix = path_prefix
  end

  def generate_report(out)
    print_headers(out)

    Dir.glob("#{path_prefix}**/{TEST,test}-*.xml")
       .group_by { |name| name.slice(path_prefix.size..).split(%(/), 2).first }
       .each { |group, test_results| process(out, group, test_results) }
  end

  private

  COUNT_XPATHS = {
    tests: 'testcase',
    passed: 'testcase[not(*)]',
    skipped: 'testcase[skipped]',
    failures: 'testcase[failure]',
    errors: 'testcase[error]',
  }.freeze

  def process(out, group, test_results)
    docs = test_results.map do |name|
      File.open(name) { |f| Nokogiri::XML f }
    end

    counts = COUNT_XPATHS.transform_values { |xpath| count(docs, xpath) }

    print_group(out, group, counts)
  end

  def count(docs, xpath)
    docs.map { |doc| doc.xpath("count(//#{xpath})") }.sum.to_i
  end

  def print_headers(out)
    out.puts '| Subproject | Status | Tests | Passed | Skipped | Failures | Errors |'
    out.puts '|------------|:------:|:-----:|:------:|:-------:|:--------:|:------:|'
  end

  def print_group(out, group, counts)
    stats = [
      group,
      (counts[:failures]).zero? && (counts[:errors]).zero? ? ':white_check_mark:' : ':x:',
      counts[:tests],
      counts[:passed],
      counts[:skipped],
      counts[:failures],
      counts[:errors],
    ]
    out.puts "| #{stats.join(' | ')} |"
  end
end
