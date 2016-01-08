# encoding: utf-8
require_relative 'reporting'

module Spinach
  class Reporter
    # The XML reporter generates a jUnit xml document describing the test run, and saves it to "./spinach.xml"
    #
    class Xml < Reporter
      include Reporting

      def initialize(*args)
        super(*args)
        @out = options[:output] || File.open('spinach.xml', 'w')
        @all_steps = []
      end

      attr_reader :all_steps

      def before_run(*)
        # override Reporting
        @suite_time = Time.now
      end

      def after_run(success)
        @elapsed_time = (Time.now - @suite_time) if @suite_time
        @timestamp = Time.now
        @test_count = all_steps.count
        @failure_count = failed_steps.count
        binding.pry
        # override Reporting
        # close timers, export report
      end

      def before_scenario(*args)
        @scenario_start_time = Time.now
      end

      def after_scenario(*args)
        current_scenario.elapsed_time = (Time.now - @scenario_start_time) if @scenario_start_time
      end

      def on_successful_step(step, step_location, step_definitions = nil)
        current_scenario.status = :success
        self.scenario = [current_feature, current_scenario, step]
        all_steps << scenario
        successful_steps << scenario
      end

      def on_failed_step(step, failure, step_location, step_definitions = nil)
        current_scenario.status = :failure
        self.scenario_error = [current_feature, current_scenario, step, failure]
        all_steps << scenario_error
        failed_steps << scenario_error
      end
    end
  end
end
