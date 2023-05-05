require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class LifetimeTrackerActionHelper
      # class methods that you define here become available in your action
      # as `Helper::LifetimeTrackerActionHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the lifetime_tracker_action plugin helper!")
      end
    end
  end
end
