#!/usr/bin/env -perl
use Cwd qw(getcwd);
#print `perl -version`;
my $cwd = getcwd();
#print $cwd."\n";		

my $dir = $cwd;

&dirrec($dir);
sub dirrec{
	my ($curdir) = @_;
	opendir(my $hendler, $curdir) or die "Can\`t open \"$curdir\".";
	
	
		while(my $curelement = readdir $hendler){
		next if ($curelement =~ /^\./);
		my $maynextdir = $curdir."/".$curelement;
		print $maynextdir."\n" if (-f $maynextdir);
		if (-d $maynextdir)	
				{
					print "Next dir: $maynextdir\n";
					&dirrec($maynextdir);
				}
		}
}


