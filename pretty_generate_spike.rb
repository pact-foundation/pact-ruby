require 'rubygems'
# require 'active_support/json'
$: << './lib'
require 'pact/term'
require 'json/pure'
require 'debugger'

term = Pact::Term.new(:generate => 'a', matcher: /a/)

debugger
puts JSON.pretty_generate(term)

hash = {a: 'beth', cde: 123}

#debugger
puts JSON.pretty_generate(hash)

