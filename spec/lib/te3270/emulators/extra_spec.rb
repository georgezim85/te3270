require 'spec_helper'

describe TE3270::Emulators::Extra do

  let(:extra) { TE3270::Emulators::Extra.new }

  before(:each) do
    WIN32OLE.stub(:connect).and_return mock_system
  end


  describe "global behaviors" do
    it 'should attempt to connect to an already running terminal' do
      WIN32OLE.should_receive(:connect).with('EXTRA.System').and_return(mock_system)
      extra.connect
    end

    it 'should start new terminal when one is not already running' do
      WIN32OLE.should_receive(:connect).and_raise "Error"
      WIN32OLE.should_receive(:new).and_return(mock_system)
      extra.connect
    end

    it 'should open a session' do
      mock_sessions.should_receive(:Open).and_return(mock_session)
      extra.connect
    end

    it 'should close all sessions if some are open' do
      mock_sessions.should_receive(:Count).and_return(1)
      mock_sessions.should_receive(:CloseAll)
      extra.connect
    end

    it 'should call a block allowing the session file to be set' do
      mock_sessions.should_receive(:Open).with('blah.edp').and_return(mock_session)
      extra.connect do |platform|
        platform.session_file = 'blah.edp'
      end
    end

    it 'should take the visible value from the block' do
      mock_session.should_receive(:Visible=).with(false)
      extra.connect do |platform|
        platform.visible = false
      end
    end

    it 'should default to visible when not specified' do
      mock_session.should_receive(:Visible=).with(true)
      extra.connect
    end

    it 'should take the window state value from the block' do
      mock_session.should_receive(:WindowState=).with(2)
      extra.connect do |platform|
        platform.window_state = :maximized
      end
    end

    it 'should default to window state normal when not specified' do
      mock_session.should_receive(:WindowState=).with(1)
      extra.connect
    end

    it 'should default to being visible' do
      mock_session.should_receive(:Visible=).with(true)
      extra.connect
    end

    it 'should get the screen for the active session' do
      mock_session.should_receive(:Screen).and_return(mock_screen)
      extra.connect
    end

    it 'should disconnect from a session' do
      mock_session.should_receive(:Close)
      mock_system.should_receive(:Quit)
      extra.connect
      extra.disconnect
    end
  end

  describe "interacting with text fields" do
    it 'should get the value from the screen' do
      mock_screen.should_receive(:GetString).with(1, 2, 10).and_return('blah')
      extra.connect
      extra.get_string(1, 2, 10).should == 'blah'
    end

    it 'should put the value on the screen' do
      mock_screen.should_receive(:PutString).with('blah', 1, 2)
      mock_screen.should_receive(:SendKeys).with('<Enter>')
      extra.connect
      extra.put_string('blah', 1, 2)
    end
  end

  describe "interacting with the screen" do
    it 'should know how to send function keys' do
      mock_screen.should_receive(:SendKeys).with('<Clear>')
      extra.connect
      extra.send_keys(TE3270.Clear)
    end

    it 'should wait for a string to appear' do
      mock_screen.should_receive(:WaitForString).with('The String')
      extra.connect
      extra.wait_for_string('The String')
    end

    it 'should wait for the host to be quiet' do
      mock_screen.should_receive(:WaitHostQuiet).with(4000)
      extra.connect
      extra.wait_for_host(4)
    end

  end
end