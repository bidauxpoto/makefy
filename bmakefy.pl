#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
$,="\t";
$\="\n";
my $target_string='$@';

$SIG{__WARN__} = sub {die @_};

my $usage = "$0 [-h|help] [-g glue]]\n";

my $help=0;
my $glue=",";
GetOptions (
	'h|help' => \$help,
	'g|glue=s' => \$glue,
) or die($usage);

if($help){
	print $usage;
	exit(0);
}

my %files=();
my $file_count=0;
my $retval="";
my $lineno=0;
while(<>){
	$lineno++;
	die("I can parse only one-line commands") if $lineno>1;

	s/^\s+|\s+$//g; #trim;
	my @F = split /\s+/,$_,-1;
	shift(@F) if $F[0]=~m/\d+/; # lose the numeber reported by history in the first column

	$retval.="\t";
	@F = map{
		s/\$/\$\$/g;
		my $suffix="";
		if(s/(\W+)$//){
			$suffix=$1;
		}
		if(-f $_){
			if(!defined($files{$_})){
				$file_count++;
				$files{$_}=$file_count;
			}
			my $dependency = $files{$_};
			if($dependency==1){
				$_='$<'
			}else{
				$_='$^'.$dependency
			}
		}
		$_.$suffix;
	} @F;
	$retval.=join(" ",@F);
}

chomp($retval);

my @dependency = sort { $files{$a} <=> $files{$b} } keys %files;
my $target=undef;
if(scalar(@dependency)>1){
	$target=pop(@dependency);
}
if(defined $target){
	$retval=~s/\$^$file_count/$target_string/;
}else{
	$retval=~s/([^\s]+)$/$target_string/;
	$target=$1;
}
#$retval=~s/|/\\\n\t|/g;
print $target .": ".join(" ",@dependency);
print $retval
