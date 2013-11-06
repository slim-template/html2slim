require_relative 'helper'
require 'tmpdir'

class TestHTML2Slim < MiniTest::Test
  def setup
    Slim::Engine.default_options[:id_delimiter] = '_'
    create_html_file
  end

  def teardown
    cleanup_tmp_files
  end

  Dir.glob("test/fixtures/*.html").each do |file|
    define_method("test_template_#{File.basename(file, '.html')}") do
      assert_valid_from_html?(file)
    end
  end

  Dir.glob("test/fixtures/*.html.erb").each do |file|
    define_method("test_template_#{File.basename(file, '.html')}") do
      assert_valid_from_erb?(file)
    end
  end

  def test_convert_slim_lang_html
    IO.popen("bin/html2slim test/fixtures/slim-lang.html -", "r") do |f|
      assert_equal File.read("test/fixtures/slim-lang.slim"), f.read
    end
  end

  def test_convert_erb
    IO.popen("bin/erb2slim test/fixtures/erb-example.html.erb -", "r") do |f|
      assert_equal File.read("test/fixtures/erb-example.html.slim"), f.read
    end
  end

  def test_convert_doctypes_hmtl
    IO.popen("bin/erb2slim test/fixtures/doctypes.html -", "r") do |f|
      assert_equal File.read("test/fixtures/doctypes.slim"), f.read
    end
  end

  def test_convert_devise_erb
    IO.popen("bin/erb2slim test/fixtures/devise-template.erb -", "r") do |f|
      assert_equal File.read("test/fixtures/devise-template.slim"), f.read
    end
  end

  def test_convert_devise_erb_2
    IO.popen("bin/erb2slim test/fixtures/devise-template-2.erb -", "r") do |f|
      assert_equal File.read("test/fixtures/devise-template-2.slim"), f.read
    end
  end

  def test_convert_file_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("bin/html2slim #{html_file} -", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  def test_convert_stdin_to_stdout
    File.open(html_file, "w") do |f|
      f.puts "<p><h1>Hello</h1></p>"
    end

    IO.popen("cat #{html_file} | bin/html2slim", "r") do |f|
      assert_equal "p\n  h1\n    | Hello\n", f.read
    end
  end

  def test_data_attributes
    html = '<a href="test" data-param1="var" data-param2="(1 + 1)" data-param3="string"></a>'
    slim = 'a[href="test" data-param1="var" data-param2="(1 + 1)" data-param3="string"]'
    assert_html_to_slim html, slim
  end

  def test_erb_tags
    # simple
    assert_erb_to_slim '<% a = 1 %>', '- a = 1'
    # simple = (puts)
    assert_erb_to_slim '<%= @a.b %>', '= @a.b'
    # no block
    assert_erb_to_slim '<% @a %>SOME<% @b %>', "- @a\n| SOME\n- @b"
    # block with do
    assert_erb_to_slim '<% @a.each do |yay| %>SOME<% yay %><% end %>', "- @a.each do |yay|\n  | SOME\n  - yay"
    # block with { and on var
    assert_erb_to_slim '<% @a.each { |yay| %>SOME<% yay %><% } %>', "- @a.each do |yay|\n  | SOME\n  - yay"
    # block without vars
    assert_erb_to_slim '<% 10.times { %>SOME<% yay %><% } %>', "- 10.times do\n  | SOME\n  - yay"
    # if
    assert_erb_to_slim '<% if 1 == 1 %>SOME<% yay %><% end %>', "- if 1 == 1\n  | SOME\n  - yay"
    # else
    assert_erb_to_slim '<% if 1 == 1 %>SOME<% yay %><% else %>OTHER<% end %>', "- if 1 == 1\n  | SOME\n  - yay\n- else\n  | OTHER"
    # elsif
    assert_erb_to_slim '<% if 1 == 1 %>SOME<% yay %><% elsif 2 == 2 %>OTHER<% end %>', "- if 1 == 1\n  | SOME\n  - yay\n- elsif 2 == 2\n  | OTHER"
    # case/when
    assert_erb_to_slim '<% case @foo %><% when 1 %>1<% when 2 %>2<% else %>3<% end %>', "- case @foo\n- when 1\n  | 1\n- when 2\n  | 2\n- else\n  | 3"
    # while
    assert_erb_to_slim '<% while @foo.next %>NEXT<% end %>', "- while @foo.next\n  | NEXT"
    # all togheter and mixed
    assert_erb_to_slim '<% while @foo.next %><% if 1 == 1 %><% for i in @foo.bar %>WORKS<% end %><% end %><% end %>', "- while @foo.next\n  - if 1 == 1\n    - for i in @foo.bar\n      | WORKS"
  end

  private

  def assert_html_to_slim(actual_html, expected_slim)
    File.open(html_file, "w") do |f|
      f.puts actual_html
    end

    IO.popen("cat #{html_file} | bin/html2slim", "r") do |f|
      assert_equal expected_slim, f.read.strip
    end
  end

  def assert_erb_to_slim(actual_erb, expected_slim)
    File.open(erb_file, "w") do |f|
      f.puts actual_erb
    end
    IO.popen("bin/erb2slim #{erb_file} -", "r") do |f|
      assert_equal expected_slim, f.read.strip
    end
  end

  def tmp_dir
    @tmp_dir ||= Dir.mktmpdir("html2slim.")
  end

  def create_html_file
    `touch #{html_file}`
  end

  def html_file
    File.join(tmp_dir, "dummy.html")
  end

  def erb_file
    File.join(tmp_dir, "dummy.html.erb")
  end

  def cleanup_tmp_files
    FileUtils.rm_rf(tmp_dir)
  end

  def assert_valid_from_html?(source)
    html = File.open(source)
    slim = HTML2Slim.convert!(html)
    assert_instance_of String, Slim::Engine.new.call(slim.to_s)
  end

  def assert_valid_from_erb?(source)
    html = File.open(source)
    slim = HTML2Slim.convert!(html, :erb)
    assert_instance_of String, Slim::Engine.new.call(slim.to_s)
  end
end
