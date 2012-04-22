Given /^there is no step matching "([^"]*)"$/ do |pattern|
  check_file_content lua_step_definitions_path, pattern, false
end

Given /^the following step definitions:$/ do |step_defs_lua_code|
  append_to_file lua_step_definitions_path, step_defs_lua_code
end

Then /^the server should respond as follows:$/ do |table|
  connect_to_wire_server do |socket|
    table.hashes.each do |hash|
      socket.puts hash["request"]
      socket.gets.strip.should == hash["response"].gsub("\n", "\\n")
    end
  end
end