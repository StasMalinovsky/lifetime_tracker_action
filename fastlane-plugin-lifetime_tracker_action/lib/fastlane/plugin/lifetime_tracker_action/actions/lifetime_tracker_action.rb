module Fastlane
  module Actions
    module SharedValues
      LIFETIME_TRACKER_CUSTOM_VALUE = :LIFETIME_TRACKER_CUSTOM_VALUE
    end

    class LifetimeTrackerAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "Starting LifeTime Tracker"
        LifetimeTracker.new.find
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "LifeTime Tracker Tool"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "LifeTime Tracker Tool..."
      end

      def self.available_options
        # Define all options your action supports.
        []
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['LIFETIME_TRACKER_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
    
    class LifetimeTracker
        def find
            all_files = Dir.glob("onPhone/**/*.swift").reject do |path|
                File.directory?(path)
            end
            error_messages = []
            warning_messages = []
            all_files.each do |file|
                is_comment_block = false
                disabled_rules = []
                filelines = File.readlines(file)
                filelines.each_with_index do |line, index|
                    if is_comment_block
                        if line.include?("*/")
                            is_comment_block = false
                        end
                    elsif line.include?("/*")
                        is_comment_block = true
                    elsif line.include?("danger:disable")
                        rule_to_disable = line.split.last
                        disabled_rules.push(rule_to_disable)
                    else
                        line2 = filelines[index+2]
                        bracket_symbol = '}'
                        only_bracket_symbol = false
                        if line2
                            line2_without_spaces = line2.gsub(/\s+/, '')
                            if line2.gsub(/\s+/, '') == bracket_symbol * line2_without_spaces.length
                                only_bracket_symbol = true
                            end
                        end
                        if line.include?("override") and line.include?("func") and filelines[index+1].include?("super") and only_bracket_symbol
                            warning_messages.push("Override methods which only call super can be removed " + File.basename(file) + " " + "#{index+3}")
                        end
                    end
                end
                next unless (File.basename(file).end_with?("Coordinator.swift") or (File.basename(file).end_with?("ViewModel.swift") and !File.basename(file).include?("Cell") ) or File.basename(file).end_with?("ViewController.swift"))
                if disabled_rules.include?("lifetime_tracking") == false
                    if File.readlines(file).grep(/LifetimeTrackable/).any?
                        error_messages.push("You forgot to call trackLifetime() from your initializers in " + File.basename(file, ".*")) unless File.readlines(file).grep(/trackLifetime()/).any?
                    else
                        warning_messages.push("Please add support for LifetimeTrackable to " + File.basename(file))
                    end
                end
            end
            warning_messages.each do |message|
                UI.important(message)
            end
            error_messages.each do |message|
                UI.error(message)
            end
            if !error_messages.empty?
                UI.user_error!("Check the error messages above")
            elsif !warning_messages.empty?
                UI.important("Check the warning messages above")
            else
                UI.success("Nicely Done!")
            end
        end
    end
    
  end
end
