#!/usr/bin/env -perl
#binmode STDOUT, ':encoding(cp1251)';
#binmode STDIN, ':encoding(cp1251)';
use strict; 
use XBase;
use Encode qw( decode encode);
use File::Copy qw( copy );
use File::Spec;
use Cwd qw(getcwd);

my $dir = getcwd();
my @list_dbf;


#foreach my $year (2016..2017){
#						mkdir $year or die "Не могу создать дирректорию $year:  $!" if (!-d $year);
#					    print "Создана папка: $year \n" if (!-d $year);
#						foreach (1..12)
#						{
#							mkdir $year."/".$_ or die "Не могу создать дирректорию $year/$_ : $!" if (!-d $year."/".$_);
#							print "Создана папка: $_ \n" if (!-d $year);
#						} 
#}

my @arry_to_sort;
my @sorted_arry;
dirrec($dir);
get_dbf_date(@list_dbf);
copy_files(@arry_to_sort);
for(@sorted_arry){ copy_to_dbf($_)};



sub dirrec{
	my ($curdir) = @_;
	my @arry_dbf = ();
	opendir(my $hendler, $curdir) or die "Can\`t open \"$curdir\".";
		while(my $curelement = readdir $hendler){
		next if ($curelement =~ /^\./);
		my $maynextdir = $curdir."/".$curelement;
      if (-f $maynextdir  && $maynextdir =~ /(9|8)0..\.\d{3}$/)
      {  
#			print $maynextdir."\n";
			push @list_dbf, $maynextdir;
#      	&copy_to_dbf($maynextdir);
      }
		if (-d $maynextdir)	
				{
					&dirrec($maynextdir);
				}
		}
}

 
 sub copy_files{
 	my @arry_to_sort = @_;
for(sort @arry_to_sort){
	if($_ =~ /^(?<year>\d{4})(?<month>..)..\b(?<fullname>.*)$/){
			my $year = $+{year};
			mkdir $year or die "Не могу создать дирректорию $year:  $!" if (!-d $year);
			my $month = $+{month};
			mkdir $year."/".$month or die "Не могу создать дирректорию $year/$_ : $!" if (!-d $year."/".$month);
			my $fullname = $+{fullname};
	if($fullname=~/(?<name>........\....)$/){
			my $name = $+{name};
			my $destination = $dir."/".$year."/".$month."/".$name;
			my @dirs;
			@dirs = File::Spec->splitdir($fullname);
			$fullname = File::Spec->catdir(@dirs);
			$fullname = substr($fullname,1,);
			@dirs = File::Spec->splitdir($destination);
			$destination = File::Spec->catdir(@dirs);
			push @sorted_arry, $destination; 
			copy("$fullname", "$destination") or die "Can\'t copy $fullname   to  \"$destination\". : $!"
	}
	}
}
 }
#copy('C:\Users\leo\git\fzHelper\out\18-01\25648018.011', 'C:\Users\leo\git\fzHelper\2016\01\25648018.011') or die "CCC"; 

#for (@list_dbf){ print $_."\n"};
 

 
sub get_dbf_date{
	my @list = @_;
	
	for my $file (@list){
	my $temptable = new XBase($file	) or die XBase->errstr();
	my $cursor = $temptable->prepare_select("DATE_P");
	my @data = $cursor->fetch;
	for(@data){
#		print $_."\t".$file."\n";	
	 	push @arry_to_sort, $_."\t".$file; 
		
	}
	}
}



 sub copy_to_dbf{
		my ($old_db) = @_;
		chomp($old_db);
		print $old_db."\n";
		my $table = new XBase($old_db) or die XBase->errstr();
		my $newtable;
		$newtable = new XBase("new") or die XBase->errstr();
			for my $recno (0 .. $table->last_record())
		        {
				        my @data = $table->get_record($recno) or die $table->errstr();
				        next if shift @data;
				        $newtable->set_record($newtable->last_record()+1, @data) or die $newtable->errstr();
		        }
		$table->close() or die $table->errstr();
		$newtable->close() or die $newtable->errstr();
 }