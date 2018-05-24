# encoding: utf-8
require_relative 'reporting'
require 'nokogiri'

module Spinach
  class Reporter
    # The XML reporter generates a jUnit xml document describing the test run, and saves it to "./spinach.xml"
    #
    class Xml < Reporter
      include Reporting

      def initialize(*args)
        super(*args)
        @out = File.open(options[:output] || 'spinach.xml', 'w')
        @all_scenarios = []
      end

      attr_reader :all_scenarios

      def before_run(*)
        # override Reporting
        @suite_time = Time.now
      end

      def after_run(success)
        @elapsed_time = (Time.now - @suite_time) if @suite_time
        @timestamp = Time.now
        @test_count = all_scenarios.count
        @failure_count = failed_steps.count

        xml = build_xml_report.to_xml
        @out.write(xml)
        @out.close
      end

      def build_xml_report
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.testsuite(name: 'spinach', tests: @test_count, failures: @failure_count, time: @elapsed_time, timestamp: @timestamp) do
            xml.properties
            @all_scenarios.each do |scenario|
              feature = scenario.feature
              case scenario.status
              when :success
                xml.testcase(classname: feature.name, name: scenario.name, file: "#{feature.filename}:#{scenario.lines.first}", time: scenario.elapsed_time)
              when :failure
                xml.testcase(classname: feature.name, name: scenario.name, file: "#{feature.filename}:#{scenario.lines.first}", time: scenario.elapsed_time) do
                  xml.failure(message: scenario.failure)
                end
              end # case scenario.status
            end
          end
        end
      end

      def around_scenario_run(scenario_data, step_definitions, &block)
        @scenario_start_time = Time.now
        block.call
        current_scenario.elapsed_time = (Time.now - @scenario_start_time) if @scenario_start_time
        all_scenarios << current_scenario
      end

      def on_successful_step(step, step_location, step_definitions = nil)
        current_scenario.status = :success
        self.scenario = [current_feature, current_scenario, step]
        successful_steps << scenario
      end

      def on_failed_step(step, failure, step_location, step_definitions = nil)
        current_scenario.status = :failure
        current_scenario.failure = failure
        self.scenario_error = [current_feature, current_scenario, step, failure]
        failed_steps << scenario_error
      end
    end
  end
end
