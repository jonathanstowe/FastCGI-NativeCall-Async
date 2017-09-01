use v6.c;

=begin pod

=head1 NAME

FastCGI::NativeCall::Async - An asynchronous wrapper for FastCGI::NativeCall

=head1 SYNOPSIS

=begin code

use FastCGI::NativeCall::Async;

my $fna = FastCGI::NativeCall::Async.new(path => "/tmp/fastcgi.sock", backlog => 32 );

my $count = 0;

react {
    whenever $fna -> $fcgi {
        say $fcgi.env;
        $fcgi.Print("Content-Type: text/html\r\n\r\n{++$count}");
    }

}

=end code

=head1 DESCRIPTION

The rationale behind this module is to help
L<FastCGI::NativeCall|https://github.com/jonathanstowe/p6-fcgi>
play nicely in a larger program by managing the blocking accept loop as
a Supply that can for instance be used in a C<react> block as above.
It doesn't actually allow more than one FastCGI request to be processed at
once for the same URI as the protocol itself precludes that.  However it
does allow more than one FastCGI handler to be present in the same Perl
6 program, potentially sharing data and other resources.

The interface is very simple and much of the functionality is delegated
to L<FastCGI::NativeCall|https://github.com/jonathanstowe/p6-fcgi>.

=head1 METHODS

=head2 method new

    method new(FastCGI::NativeCall::Async:U:  Str :$path, Int :$backlog = 16)

The constructor must be supplied with the path where the listening Unix domain
socket will be created, the location must be accessible to both your program
and the host HTTP server which will be delivering the requests.  

The C<backlog> option, which defaults to 16, is the number of yet to be 
accepted requests that can be queued before subsequent requests receive
an error, you may want to adjust this (in concert with the configuration
of your host HTTP server,) to achieve an acceptable level of throughput
for your application.

=head2 method Supply

    method Supply(FastCGI::NativeCall::Async:D: --> Supply)

This returns a L<Supply> on to which the L<FastCGI::NativeCall> object
is emitted for each incoming request. This acts as a coercion on the
FastCGI::NativeCall::Async object so may not need to be typed explicitly
in some places (such as in a C<whenever> of a C<react> block as in the
Synopsis.)

=end pod

class FastCGI::NativeCall::Async {
    use FastCGI::NativeCall;

    has Str $.path    is required;
    has Int $.backlog is default(16);

    has FastCGI::NativeCall $!fcgi;

    method fcgi( --> FastCGI::NativeCall) {
        $!fcgi //= FastCGI::NativeCall.new(:$!path, :$!backlog);
    }

    has Supplier $!supplier;

    method supplier(--> Supplier) {
        $!supplier //= Supplier.new;
    }

    has Supply $!supply;

    has $!promise;
    method Supply( --> Supply) {
        if !$!supply.defined {
            $!supply = self.supplier.Supply;
            $!promise = start {
                while self.fcgi.accept {
                    self.supplier.emit(self.fcgi);
                }
            }
        }
        $!supply;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
