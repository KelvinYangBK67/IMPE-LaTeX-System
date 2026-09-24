use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;

my $manual_dir = abs_path(dirname(__FILE__));
my $repo_root = abs_path(File::Spec->catdir($manual_dir, '..', '..'));
my $path_separator = ($^O eq 'MSWin32' || $^O eq 'cygwin') ? ';' : ':';
my $existing_texinputs = $ENV{'TEXINPUTS'} // '';
my @texinputs = (
    File::Spec->catdir($repo_root, 'package'),
    $repo_root
);
push @texinputs, $existing_texinputs if length $existing_texinputs;
push @texinputs, '';

$ENV{'TEXINPUTS'} = join($path_separator, @texinputs);
$ENV{'SOURCE_DATE_EPOCH'} = '1790035200'
    unless defined $ENV{'SOURCE_DATE_EPOCH'} && $ENV{'SOURCE_DATE_EPOCH'} =~ /^\d+$/;
$ENV{'FORCE_SOURCE_DATE'} = '1';

$pdf_mode = 5;
$do_cd = 1;
