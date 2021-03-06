use ExtUtils::MakeMaker;

use Config;

my $backend;

if (defined $ENV{MATH_INT64_BACKEND}) {
    $backend = $ENV{MATH_INT64_BACKEND}
}
elsif ($Config::Config{ivsize} >= 8) {
    $backend = 'IV';
}
elsif ($Config::Config{doublesize} >= 8) {
    $backend = 'NV';
}
else {
    # $backend = 'STRING';
    die "unable to find a suitable backend for your platform";
}

print "Using $backend backend\n";

unless ($Config{i64type} and
        $Config{i64size} == 8 and
	($Config{d_int64_t} or $^O =~ /MSWin32/i)) {
    die "Your C compiler does not have enough support for int64 values\n";
}

my @define = ("INT64_BACKEND_" . $backend);

my $define = join (' ', map { "-D$_" } @define);

WriteMakefile( NAME           => 'Math::Int64',
               VERSION_FROM   => 'lib/Math/Int64.pm',
               PREREQ_PM      => {},
               ABSTRACT_FROM  => 'lib/Math/Int64.pm', # retrieve abstract from module
               AUTHOR         => 'Salvador Fandino <sfandino@yahoo.com>',
               LIBS           => [''], # e.g., '-lm'
               # OPTIMIZE       => '-O0 -g',
               DEFINE         => $define,
               INC            => '-I.', # e.g., '-I. -I/usr/include/other',
               META_MERGE     => {
                   resources => {
                       repository  =>  'https://github.com/salva/p5-Math-Int64',
                   },
               },
    );


package MY;

sub postamble {
    my $self = shift;
    my $author = $self->{AUTHOR};
    $author = join(', ', @$author) if ref $author;
    $author =~ s/'/'\''/g;
    my $q = $^O =~ /MSWin32/i ? '"' : "'";
    return <<MAKE_FRAG

c_api.h: c_api.decl
	make_perl_module_c_api module_name=\$(NAME) module_version=\$(VERSION) author=$q$author$q
MAKE_FRAG

}

sub init_dirscan {
    my $self = shift;
    $self->SUPER::init_dirscan(@_);
    push @{$self->{H}}, 'c_api.h' unless grep $_ eq 'c_api.h', @{$self->{H}};
}
