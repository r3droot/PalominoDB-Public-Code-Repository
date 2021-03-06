# 013_mysqlinstance_config.deb.t
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
use Test::More tests => 2;
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
  skip 'this only valid on debian', 2 if(! -f "/etc/debian_version");
  skip 'Need TEST_SSH_HOST and TEST_SSH_USER', 2 if(!$ENV{TEST_SSH_HOST} or !$ENV{TEST_SSH_USER});
  my $server_pkg;
  chomp($server_pkg = qx{dpkg-query -W mysql-server 2>/dev/null});
  diag("It's OK to ignore failures since you don't appear to have mysql-server installed") unless($server_pkg =~ /\d/);
  my $l = MysqlInstance->new('localhost');
  is_deeply($l->config, $default_config, 'local config');
  my $r = MysqlInstance->new($ENV{TEST_SSH_HOST}, $ENV{TEST_SSH_USER});
  is_deeply($l->config, $default_config, 'remote config');
}

