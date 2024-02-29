#! @perl@/bin/perl -w

use strict;
use DBI;
use DBD::SQLite;
use String::ShellQuote;
use Config;

my $program = $ARGV[0];

my $dbPath = "@dbPath@";

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbPath", "", "")
    or die "cannot open database `$dbPath'";
$dbh->{RaiseError} = 0;
$dbh->{PrintError} = 0;

my $system = $ENV{"NIX_SYSTEM"} // $Config{myarchname};

my $res = $dbh->selectall_arrayref(
  "select package from Programs where system = ? and name = ?",
  { Slice => {} }, $system, $program);

if (!defined $res || scalar @$res == 0) {
  print STDERR "$program: command not found\n";
} 
else {
  if ($ENV{"NIX_AUTO_RUN"} // "") {
    my @options = map {$_->{package}} @$res;
    my $optionStr = join("\n", @options);
    my $selection = `echo '$optionStr' | @fzf@/bin/fzf --select-1 --min-height=6 --header="Choose source nix package" --preview-label="Package info" --preview="\"@previewer@\" {}"`;

    if ($selection eq "") {
      # No selection -> exit
      exit 127;
    }

    exec("nix-shell", "-p", $selection, "--run", shell_quote("exec", @ARGV));
  }
  print STDERR <<EOF;
The program '$program' is not in your PATH.
You can make it available in an ephemeral shell by typing one of the following:
EOF
  print STDERR "  nix-shell -p $_->{package}\n" foreach @$res;
}

exit 127;
