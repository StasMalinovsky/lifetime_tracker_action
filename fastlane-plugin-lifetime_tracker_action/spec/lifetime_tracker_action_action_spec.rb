describe Fastlane::Actions::LifetimeTrackerActionAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The lifetime_tracker_action plugin is working!")

      Fastlane::Actions::LifetimeTrackerActionAction.run(nil)
    end
  end
end
