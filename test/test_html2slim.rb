require_relative 'helper'
require 'tmpdir'

class TestHTML2Slim < MiniTest::Unit::TestCase
  def setup
    Slim::Engine.default_options[:id_delimiter] = '_'
    create_html_file
  end

  def teardown
    cleanup_tmp_files
  end

  Dir.glob("test/fixtures/*.html").each do |file|
    define_method("test_template_#{File.basename(file, '.html')}") do
      assert_valid?(file)
    end
  end

  def test_convert_slim_lang_html
    IO.popen("bin/html2slim test/fixtures/slim-lang.html -", "r") do |f|
      assert_equal File.read("test/fixtures/slim-lang.slim"), f.read
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


  private

  def assert_html_to_slim(actual_html, expected_slim)
    File.open(html_file, "w") do |f|
      f.puts actual_html
    end

    IO.popen("cat #{html_file} | bin/html2slim", "r") do |f|
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

  def cleanup_tmp_files
    FileUtils.rm_rf(tmp_dir)
  end

  def assert_valid?(source)
    html = File.open(source)
    slim = HTML2Slim.convert!(html)
    assert_instance_of String, Slim::Engine.new.call(slim.to_s)
  end
end