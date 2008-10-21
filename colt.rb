require 'rubygems'
require 'colt_app'

begin
  colt = ColtApp.new("")
  colt.run
ensure
  ColtApp.close
end

