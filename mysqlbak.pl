#!/usr/bin/perl 

# mysql.bak - (c) Jim Salter, licensed GPLv3
# See https://www.gnu.org/licenses/gpl-3.0.en.html if you did not
# receive a full copy of the GPLv3 with this project.

# Usage:
#   mysqlbak /etc/mysqlbak/mysqlbak.conf
# 
# reads $host, $user, and $password as one single line apiece 
# from config file specified as the argument passed to the program. 
# backs up all databases at $host to individual gzipped dumpfiles 
# in the current directory.

# Sample mysqlbak.conf:
#
#   yourbox.com
#   root
#   mysqlrootpassword

$noisy = 0; 
open CONF, $ARGV[0]; 
$host = <CONF>; 
$user = <CONF>; 
$password = <CONF>; 
close CONF;

chomp $host; 
chomp $user; 
chomp $password; 

$mysql = '/usr/bin/mysql'; 
$mysqldump = '/usr/bin/mysqldump'; 
$grep = '/bin/grep'; 
$gzip = '/bin/gzip';

if ($noisy) { $gzip = '/usr/bin/pv |' . $gzip; }

@databases = `echo show databases | $mysql -u $user -h $host -p'$password' | $grep -v information_schema`; 
delete $databases[0]; 
$dblist = join (' ', @databases); 
$dblist =~ s/\n//g;

open DUMP, "$mysqldump -C --flush-logs --single-transaction -u $user -h $host -p'$password' --databases$dblist |"; 
do { 
  $line = <DUMP>; 
  push @header, $line; 
} until ($line =~ /^-- Current Database/); 

pop @header; 

open OUT, "> /dev/null"; 

do { 
  if ($line =~ /^-- Current Database/) { 
    close OUT; (my $db) = ($line =~ /.*\`(\w*)\`/); 
    if ($noisy) { print "Backing up $db:\n"; } 
    open OUT, "| $gzip --rsyncable > $db.sql.gz"; 
    print OUT @header; 
    print OUT $line; 
  } else { 
    print OUT $line; 
  } 
} while ($line = <DUMP>); 

close OUT; 
close DUMP;

exit 0;
