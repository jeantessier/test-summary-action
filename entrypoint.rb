#!/usr/bin/env ruby

require './lib/report_generator'

path_prefix = case
              when ENV.has_key?('GITHUB_WORKSPACE')
                ENV['GITHUB_WORKSPACE'] + "/"
              when Dir.exist?("/github/workspace")
                "/github/workspace/"
              else
                ""
              end

report_generator = ReportGenerator.new path_prefix

if ENV.has_key?"GITHUB_STEP_SUMMARY"
  File.open(ENV["GITHUB_STEP_SUMMARY"], "a") do |out|
    report_generator.generate_report out
  end
else
  report_generator.generate_report STDOUT
end
