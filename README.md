![Version](https://img.shields.io/gem/v/html2slim.svg)

[![Build Status](https://travis-ci.org/slim-template/html2slim.png?branch=master)](https://travis-ci.org/slim-template/html2slim)

[![Code climate](https://codeclimate.com/github/slim-template/html2slim.png)](https://codeclimate.com/github/slim-template/html2slim)

## HTML2Slim

Script for converting HTML and ERB files to [slim](http://slim-template.github.io/).

## Usage

You may convert files using the included executables `html2slim` and `erb2slim`.

    # html2slim -h

    Usage: html2slim INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
            --trace                      Show a full traceback on error
        -d, --delete                     Delete HTML files
        -h, --help                       Show this message
        -v, --version                    Print version

    # erb2slim -h

    Usage: erb2slim INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
            --trace                      Show a full traceback on error
        -d, --delete                     Delete ERB files
        -h, --help                       Show this message
        -v, --version                    Print version

Alternatively, to convert files or strings on the fly in your application, you may do so by calling `HTML2Slim.convert!(file, format)` where format is either `:html` or `:erb`.

## License

This project is released under the MIT license.

## Author

[Maiz Lulkin](https://github.com/joaomilho) and [contributors](https://github.com/slim-template/html2slim/graphs/contributors)

## OFFICIAL REPO

[https://github.com/slim-template/html2slim](https://github.com/slim-template/html2slim)

## GOOD TO KNOW

ERB requires a full Ruby parser, so it doesn't really work for all use cases, but it's certainly helpful.
