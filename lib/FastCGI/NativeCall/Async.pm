use v6.c;

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
