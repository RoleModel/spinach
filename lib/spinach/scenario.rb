module Spinach
  class Scenario
    attr_accessor :lines
    attr_accessor :name, :steps, :tags, :feature
    attr_accessor :status, :elapsed_time, :failure

    def initialize(feature)
      @feature = feature
      @steps   = []
      @tags    = []
      @lines   = []
    end
  end
end
