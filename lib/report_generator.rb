require 'nokogiri'

class ReportGenerator
  attr_reader :path_prefix
  attr_reader :source

  def initialize(path_prefix, source)
    @path_prefix = path_prefix
    @source = source
  end

  def generate_report(out)
    out.puts "| Subproject | Status | Tests | Passed | Skipped | Failures | Errors |"
    out.puts "|------------|:------:|:-----:|:------:|:-------:|:--------:|:------:|"

    Dir.glob(path_prefix + source)
       .group_by {|name| name.slice(path_prefix.size..).split(%'/', 2).first}
       .each do |group, test_results|
      docs = test_results.map do |name|
        File.open(name) {|f| Nokogiri::XML f}
      end

      counts = {
        tests: docs.map {|doc| doc.xpath("count(//testcase)")}.sum.to_i,
        passed: docs.map {|doc| doc.xpath("count(//testcase[not(*)])")}.sum.to_i,
        skipped: docs.map {|doc| doc.xpath("count(//testcase[skipped])")}.sum.to_i,
        failures: docs.map {|doc| doc.xpath("count(//testcase[failure])")}.sum.to_i,
        errors: docs.map {|doc| doc.xpath("count(//testcase[error])")}.sum.to_i,
      }

      status = counts[:failures] == 0 && counts[:errors] == 0

      out.puts "| #{group} | #{status ? ":white_check_mark:" : ":x:"} | #{counts[:tests]} | #{counts[:passed]} | #{counts[:skipped]} | #{counts[:failures]} | #{counts[:errors]} |"
    end
  end
end
