require 'aruba/cucumber'
require 'childprocess'

module WireServerHost
  include Aruba::Api

  def lua_step_definitions_path
    "features/step_definitions/steps.lua"
  end

  def start_wire_server
    write_file lua_step_definitions_path, ""
    write_file "host.lua", lua_host
    in_current_dir do
      spawn_server_process
    end
  end

  def connect_to_wire_server
    socket = TCPSocket.new( "127.0.0.1", 9666 )
    yield socket
    socket.close
  end

  def stop_wire_server
    until @server.exited?
      @server.stop
    end
  end

  private

  def lua_host
    %{
      package.path = '#{src_path}/?.lua;' .. package.path
      require("cucumber"):StartListening()
    }
  end

  def spawn_server_process
    @server = ChildProcess.build("lua", "host.lua")
    @server.io.inherit!
    @server.start
    await_server_response
  end

  def await_server_response
    begin
      @socket = TCPSocket.new( "127.0.0.1", 9666 )
      @socket.puts '["step_matches",{"name_to_match":"Given a server"}]'
      @socket.gets.should =~ /success/
    rescue
      retry
    end
    @socket.close
  end

  def src_path
    File.expand_path(File.join(File.dirname(__FILE__), "../../src"))
  end
end

World(WireServerHost)

Before do
  start_wire_server
end

After do
  stop_wire_server
end
