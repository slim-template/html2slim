require 'optparse'
require 'html2slim'

module HTML2Slim
  class Command
    def initialize(args)
      @args    = args
      @options = {}
    end

    def run
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)
      process!
      exit 0
    rescue Exception => ex
      raise ex if @options[:trace] || SystemExit === ex
      $stderr.print "#{ex.class}: " if ex.class != RuntimeError
      $stderr.puts ex.message
      $stderr.puts '  Use --trace for backtrace.'
      exit 1
    end

    protected

    def set_opts(opts)
      opts.banner = "Usage: html2slim INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]"

      opts.on('--trace', :NONE, 'Show a full traceback on error') do
        @options[:trace] = true
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end

      opts.on_tail('-v', '--version', 'Print version') do
        puts "html2slim #{HTML2Slim::VERSION}"
        exit
      end

      opts.on('-d', '--delete', 'Delete HTML files') do
        @options[:delete] = true
      end
    end

    def process!
      args = @args.dup

      @options[:input]  = file        = args.shift
      @options[:output] = destination = args.shift

      @options[:input] = file = "-" unless file

      if File.directory?(@options[:input])
        Dir["#{@options[:input]}/**/*.html"].each { |file| _process(file, destination) }
      else
        _process(file, destination)
      end
    end

    private

    def _process(file, destination = nil)
      require 'fileutils'
      slim_file = file.sub(/\.html$/, '.slim')

      if File.directory?(@options[:input]) && destination
        FileUtils.mkdir_p(File.dirname(slim_file).sub(@options[:input].chomp('/'), destination))
        slim_file.sub!(@options[:input].chomp('/'), destination)
      else
        slim_file = destination || slim_file
      end

      in_file = if @options[:input] == "-"
                  $stdin
                else
                  File.open(file, 'r')
                end

      @options[:output] = slim_file && slim_file != '-' ? File.open(slim_file, 'w') : $stdout
      # raise "|||#{self.class.inspect}|||"
      @options[:output].puts HTML2Slim.convert!(in_file, (self.class.to_s =~ /ERB/ ? :erb : :html))
      @options[:output].close

      File.delete(file) if @options[:delete]
    end
  end
  class HTMLCommand < Command
  end
  class ERBCommand < Command
  end
end
