#!/usr/bin/env ruby -I lib

require 'report_generator'

path_prefix = case
              when ENV.key?('GITHUB_WORKSPACE')
                "#{ENV.fetch('GITHUB_WORKSPACE')}/"
              when Dir.exist?('/github/workspace')
                '/github/workspace/'
              else
                ''
              end

report_generator = ReportGenerator.new path_prefix

if ENV.key? 'GITHUB_STEP_SUMMARY'
  File.open(ENV['GITHUB_STEP_SUMMARY'], 'a') do |out|
    report_generator.generate_report out
  end
else
  report_generator.generate_report $stdout
end
