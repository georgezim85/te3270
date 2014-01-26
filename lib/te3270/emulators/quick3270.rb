require 'win32ole'
require 'win32/screenshot'

module TE3270
  module Emulators
    class Quick3270

      attr_reader :system, :session, :screen
      attr_writer :visible, :server_name, :port_number

      def connect
        start_quick_system
        yield self if block_given?
        raise "The server name must be set in a block when calling connect with the Quick3270 emulator." if @server_name.nil?
        establish_session
      end

      def disconnect
        session.Disconnect
        system.Application.Quit
      end

      def get_string(row, column, length)
        screen.GetString(row, column, length)
      end

      def put_string(str, row, column)
        screen.MoveTo(row, column)
        screen.PutString(str)
        screen.SendKeys(TE3270.Enter)
      end

      def send_keys(keys)
        screen.SendKeys(keys)
      end

      def wait_for_string(str, row, column)
        screen.WaitForString(str, row, column)
      end

      def wait_for_host(seconds)
        screen.WaitHostQuiet(seconds * 1000)
      end

      def screenshot(filename)
        title = session.WindowTitle
        Win32::Screenshot::Take.of(:window, title: title).write(filename)
      end

      def text
        rows = screen.Rows
        columns = screen.Cols
        result = ''
        rows.times do |row|
          result += "#{screen.GetString(row+1, 1, columns)}\\n"
        end
        result
      end

      private

      def visible
        @visible.nil? ? true : @visible
      end

      def start_quick_system
        begin
          @system = WIN32OLE.connect('Quick3270.Application')
        rescue
          @system = WIN32OLE.new('Quick3270.Application')
        end
      end

      def establish_session
        system.Visible = visible
        @session = system.ActiveSession
        session.Server_Name = @server_name
        session.PortNumber = @port_number unless @port_number.nil?
        @screen = session.Screen
        session.Connect
      end

    end
  end
end