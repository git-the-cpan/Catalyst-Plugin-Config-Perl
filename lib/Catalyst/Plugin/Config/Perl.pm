package Catalyst::Plugin::Config::Perl;
use 5.012;
use Panda::Lib 'fclone';
use Panda::Config::Perl;

our $VERSION = '1.0.0';

use Class::Accessor::Inherited::XS inherited => [qw/cfg dev/];

sub setup {
    my $class = shift;
    #my $start = Time::HiRes::time();

    my $initial_cfg = $class->config;
    $class->cfg($initial_cfg);
    my $self_cfg = $initial_cfg->{'Plugin::Config::Perl'} || {};
    $initial_cfg->{home} = Path::Class::Dir->new($initial_cfg->{home}) unless ref $initial_cfg->{home};
    
    my $conf_file;
    if ($self_cfg->{file}) {
        $conf_file = $initial_cfg->{home}->file($self_cfg->{file});
    } else {
        my $local_file = $initial_cfg->{home}->file('local.conf');
        if (-f $local_file) { $conf_file = $local_file }
        else {
            my $main_file = $initial_cfg->{home}->file('conf/'.lc($class).'.conf');
            $conf_file = $main_file if -f $main_file;
        }
    }
    
    if ($conf_file) {
        my $cfg = Panda::Config::Perl->process($conf_file, $initial_cfg);
        $class->config($cfg);
        $class->cfg($cfg);
    } else {
        $class->cfg($initial_cfg);
    }

    #print "ConfigSuite Init took ".((Time::HiRes::time() - $start)*1000)."\n";
    $class->finalize_config if $class->can('finalize_config');
    $class->next::method(@_);
}

1;