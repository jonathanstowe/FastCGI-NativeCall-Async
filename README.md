# FastCGI::NativeCall::Async

An asynchronous wrapper for [FastCGI::NativeCall](https://github.com/jonathanstowe/FastCGI-NativeCall/)

## Synopsis

```perl6
use FastCGI::NativeCall::Async;

my $fna = FastCGI::NativeCall::Async.new(path => "/tmp/fastcgi.sock", backlog => 32 );

my $count = 0;

react {
    whenever $fna -> $fcgi {
	    say $fcgi.env;
        $fcgi.Print("Content-Type: text/html\r\n\r\n{++$count}");
    }

}
```

## Description

The rationale behind this module is to help
[FastCGI::NativeCall](https://github.com/jonathanstowe/FastCGI-NativeCall/)
play nicely in a larger program by managing the blocking accept loop as
a Supply that can for instance be used in a ```react``` block as above.
It doesn't actually allow more than one FastCGI request to be processed at
once for the same URI as the protocol itself precludes that.  However it
does allow more than one FastCGI handler to be present in the same Perl
6 program, potentially sharing data and other resources.

## Installation

Assuming you have a working Rakudo Perl installation you should be able to
install this with *zef* :

     zef install FastCGI::NativeCall::Async

     # Or from a local clone 

     zef install .

## Support

Please send any suggestions/patches etc to https://github.com/jonathanstowe/FastCGI-Native-Async/issues

## Licence && Copyright

This is free software see the [LICENCE](LICENCE) file in the distribution.

© 2017 Jonathan Stowe
