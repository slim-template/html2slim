[![Build Status](https://travis-ci.org/slim-template/html2slim.png?branch=master)](https://travis-ci.org/slim-template/html2slim)

## HTML2Slim

Script for converting HTML (or sHTML) files to slim (slim-lang.org).

It's not perfect, but certainly it helps a lot!

It's based on Hpricot. Yeah, I'm old school.

## Usage

You may convert files using the included executable `html2slim`.

    # html2slim -h

    Usage: html2slim INPUT_FILENAME_OR_DIRECTORY [OUTPUT_FILENAME_OR_DIRECTORY] [options]
            --trace                      Show a full traceback on error
        -d, --delete                     Delete HTML files
        -h, --help                       Show this message
        -v, --version                    Print version

Alternatively, to convert files or strings on the fly in your application, you may do so by calling `HTML2Slim.convert!`.

## License

This project is released under the MIT license.

## Author

[Maiz Lulkin] (https://github.com/joaomilho)

## OFFICIAL REPO

https://github.com/slim-template/html2slim

## ROADMAP

1. Improve minitests
2. ERB support, I guess...
3. Merge with other *2slim gems. Would be handy.