require 'nokogiri'

def generate_report(out)
  out.puts "| Subproject | Status | Tests | Passed | Skipped | Failures | Errors |"
  out.puts "|------------|:------:|:-----:|:------:|:-------:|:--------:|:------:|"

  Dir.glob('/github/workspace/*/build/test-results/test/TEST-*.xml')
     .group_by {|name| name.split(%'/', 5)[3]}
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

def dump_env(out)
  out.puts "| Name | Value |"
  out.puts "|------|-------|"

  ENV.sort.each do |name, value|
    out.puts "| #{name} | #{value} |"
  end
end

# Main

if ENV.has_key?"GITHUB_STEP_SUMMARY"
  File.open(ENV["GITHUB_STEP_SUMMARY"], "a") do |f|
    dump_env f
    f.puts
    generate_report f
  end
else
  dump_env STDOUT
  puts
  generate_report STDOUT
end
