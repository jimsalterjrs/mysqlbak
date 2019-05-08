# mysqlbak
CLI tool to dump mysql dbs per-db

USAGE: `mysqlbak /etc/mysqlbak/mysqlserver.mysqlbak.conf`

where `/etc/mysqlbak/mysqlserver.mysqlbak.conf` looks like this:

    mysqlserver.mydomain.com
    root
    mysqlrootpasswd

When run as above, mysqlbak.pl connects to the machine at `mysqlserver.domain.com` on the standard mysql port, logs in to mysql as user `root` with password `mysqlrootpasswd`, then dumps all databases as individual files.

It splits each database and table into its own file, which it gzips and saves into the current directory; sample output will look something like this:

    mysql.sql.gz
    wordpress.sql.gz
    sys.sql.gz
