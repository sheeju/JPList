use Test::More;
use DBI;
use Data::Dumper;
use FindBin;

our $dbfile="$FindBin::Bin/sqlite3.test.db";
 
my $dbh=DBI->connect("dbi:SQLite:$dbfile",'','',
                       {RaiseError=>1, PrintError=>0, AutoCommit=>0});

# add unit tests here ...	
pass("Starting unitit test");
print Dumper $dbh;
$sth = $dbh->prepare('SELECT * FROM "Items"') or die("$!");
my $data = $dbh->selectall_arrayref($sth, {Slice => {}}) or die("$!");

print Dumper $data;

done_testing;
