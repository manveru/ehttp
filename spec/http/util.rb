require 'spec/helper'

describe HTTP::Util do
  should 'crunch cookies' do
    crunch = lambda{|c| HTTP::Util.cookie_cruncher(c) }

    cookie = "session_id-client = DsG--c5205a; path = /"
    crunch[cookie].should == {
      "session_id-client" => {
        "value" => "DsG--c5205a",
        "path" => "/"}}

    cookie = "session=al98axx; expires=Fri, 31-Dec-1999 23:58:23, path=/, query=rubyscript; path=/, expires=Fri, 31-Dec-1999 23:58:23"
    crunch[cookie].should == {
      "session" => {
        "expires" => "Fri, 31-Dec-1999 23:58:23",
        "value" => "al98axx",
        "path" => "/"},
      "query" => {
        "expires" => "Fri, 31-Dec-1999 23:58:23",
        "value" => "rubyscript",
        "path" =>  "/"}}

    cookie = 'session=123; path = /, expires=Mon, 18 Aug 2008 12:37:42 GMT, role=innocent bystander; path=/home, expires=Mon, 18 Aug 2008 12:38:42 GMT'
    crunch[cookie].should == {
      "session" => {
        "expires" => "Mon, 18 Aug 2008 12:37:42 GMT",
        "value" => "123",
        "path" => "/"},
      "role" => {
        "expires" => "Mon, 18 Aug 2008 12:38:42 GMT",
        "value" => "innocent bystander",
        "path" => "/home"}}
  end
end
