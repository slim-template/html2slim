# -*- encoding: utf-8 -*-
require File.expand_path("../lib/html2slim/version", __FILE__)
require "date"

Gem::Specification.new do |s|
  s.name             = "html2slim"
  s.version          = HTML2Slim::VERSION
  s.date             = Date.today.to_s
  s.authors          = ["Maiz Lulkin"]
  s.email            = ["maiz@lulk.in"]
  s.summary          = %q{HTML to Slim converter.}
  s.description      = %q{Convert HTML to Slim templates. Because HTML sux and Slim rules. That's why.}
  s.homepage         = %q{https://github.com/slim-template/html2slim}
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_paths    = ["lib"]
  s.files            = `git ls-files --  lib/* bin/* README.md`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency "hpricot"
  s.add_development_dependency 'minitest'
  s.add_development_dependency "slim", [">= 1.0.0"]
end