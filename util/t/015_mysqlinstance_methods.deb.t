# 015_mysqlinstance_methods.deb.t
# Copyright (C) 2013 PalominoDB, Inc.
# 
# You may contact the maintainers at eng@palominodb.com.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings FATAL => 'all';
use Test::More tests => 5;
use TestUtil;
use MysqlInstance;

my $default_config = {
          'client' => {
                        'port' => '3306',
                        'socket' => '/var/run/mysqld/mysqld.sock'
                      },
          'isamchk' => {
                         'sort_buffer_size' => '8M',
                         'key_buffer' => '8M'
                       },
          'myisamchk' => {
                           'sort_buffer_size' => '8M',
                           'key_buffer' => '8M'
                         },
          'mysqldump' => {
                           'max_allowed_packet' => '16M',
                           'quick' => 1
                         },
          'mysql' => {
                       'no-auto-rehash' => 1
                     },
          'mysqld' => {
                        'net_buffer_length' => '2K',
                        'max_allowed_packet' => '1M',
                        'thread_stack' => '64K',
                        'skip-locking' => 1,
                        'server-id' => '1',
                        'port' => '3306',
                        'read_rnd_buffer_size' => '256K',
                        'table_cache' => '4',
                        'socket' => '/var/run/mysqld/mysqld.sock',
                        'sort_buffer_size' => '64K',
                        'read_buffer_size' => '256K',
                        'key_buffer' => '16K'
                      },
          'mysqlhotcopy' => {
                              'interactive-timeout' => 1
                            }
        };


SKIP: {
  skip 'this only valid on debian', 5 if(! -f "/etc/debian_version");
  my $mths = MysqlInstance::Methods->detect;
  is($mths->{start}, '/etc/init.d/mysql start &>/dev/null', 'start cmd');
  is($mths->{stop}, '/etc/init.d/mysql stop &>/dev/null', 'stop cmd');
  is($mths->{restart}, '/etc/init.d/mysql restart &>/dev/null', 'restart cmd');
  is($mths->{status}, '/etc/init.d/mysql status &>/dev/null', 'restart cmd');
  is($mths->{config}, '/etc/mysql/my.cnf', 'config path');
  my $server_pkg;
  chomp($server_pkg = qx{dpkg-query -W mysql-server 2>/dev/null});
  diag("It's OK to ignore these failures since you don't appear to have mysql-server installed") unless($server_pkg =~ /\d/);
}
