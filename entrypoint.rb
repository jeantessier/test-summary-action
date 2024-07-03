#!/usr/bin/env ruby

require 'nokogiri'

def generate_report(out)
  out.puts "| Subproject | Status | Tests | Passed | Skipped | Failures | Errors |"
  out.puts "|------------|:------:|:-----:|:------:|:-------:|:--------:|:------:|"

  path_prefix = if ENV.has_key?('GITHUB_WORKSPACE')
                  ENV['GITHUB_WORKSPACE'] + "/"
                elsif Dir.exist?("/github/workspace")
                  "/github/workspace/"
                else
                  ""
                end

  Dir.glob("#{path_prefix}*/build/test-results/test/TEST-*.xml")
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

# Main

if ENV.has_key?"GITHUB_STEP_SUMMARY"
  File.open(ENV["GITHUB_STEP_SUMMARY"], "a") do |f|
    generate_report f
  end
else
  generate_report STDOUT
end
