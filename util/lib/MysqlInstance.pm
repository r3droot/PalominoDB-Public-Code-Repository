# MysqlInstance.pm - Detects MySQL init scripts.
# Copyright (C) 2009-2013 PalominoDB, Inc.
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

package MysqlInstance::Methods;
use strict;
use warnings FATAL => 'all';
use Carp;

sub new {
  my ($class, $start, $stop, $restart, $status, $config) = @_;
  my $self = {};
  $self->{start} = $start;
  $self->{stop} = $stop;
  $self->{restart} = $restart;
  $self->{status} = $status;
  $self->{config} = $config;
  return bless $self, $class;
}

sub detect {
  my ($class) = @_;

  if($^O eq 'linux') {
    return $class->new(_identify_linux());
  }
  elsif($^O eq 'freebsd') {
    return $class->new(_identify_freebsd());
  }
  return $class->new();
}

sub _identify_linux {
  if($^O eq 'linux') {
    if(-f '/etc/debian_version') {
      if( ! -f '/etc/init.d/mysql' or ! -f '/etc/mysql/my.cnf' ) {
          return (undef, undef, undef, undef, undef);
      }
      return (
        '/etc/init.d/mysql start &>/dev/null',
        '/etc/init.d/mysql stop &>/dev/null',
        '/etc/init.d/mysql restart &>/dev/null',
        '/etc/init.d/mysql status &>/dev/null',
        '/etc/mysql/my.cnf'
      );
    }
    elsif( -f '/etc/redhat-release' ) {
      if( ! -f '/etc/init.d/mysql' or ! -f '/etc/my.cnf' ) {
          return (undef, undef, undef, undef, undef);
      }
      return (
        '/etc/init.d/mysql start 2>&1 | grep -q OK',
        '/etc/init.d/mysql stop  2>&1 | grep -q OK',
        '/etc/init.d/mysql restart 2>&1 | grep -q OK',
        '/etc/init.d/mysql status &>/dev/null',
        '/etc/my.cnf'
      );
    }
  }
  return (undef, undef, undef, undef, undef);
}

sub _identify_freebsd {
  if($^O eq 'freebsd' and -f '/usr/local/etc/rc.d/mysql-server') {
      return (
        '/usr/local/etc/rc.d/mysql-server start &>/dev/null',
        '/usr/local/etc/rc.d/mysql-server stop  &>/dev/null',
        '/usr/local/etc/rc.d/mysql-server restart &>/dev/null',
        '/usr/local/etc/rc.d/mysql-server status &>/dev/null',
        '/etc/my.cnf'
      );
  }
  return (undef, undef, undef, undef, undef);
}

1;

=pod

=head1 NAME

MysqlInstance::Methods - Detects mysqld init scripts

=head1 SYNOPSIS

This package is primarily for use in L<MysqlInstance>.
However, if this package fails to properly detect settings for your system,
you may create one manually and pass it to a L<MysqlInstance> object.

=head1 DETECTION

Detection is done by examining a few files under C</etc> and looking at C<$^O>.

=head1 SUPPORTED SYSTEMS

=over 8

=item RedHat and derivatives

RedHat based distributions are detected by finding C</etc/redhat_release>.

=item Debian and derivatives

Debian based distributions are detected by finding C</etc/debian_version>.

=item FreeBSD

FreeBSD hosts are detected by finding C<$^O> equal to C<'freebsd'>.

=back

=head1 CUSTOM INSTANCES

Ocassionally, it's required to manually create instances of this package
when automated detection fails, or, when mysql is installed in a
non-standard location. 

The only requirement this package places on such instances is that the methods
supplied do not return ANY information on stdout/err.

=head1 METHODS

=over 8

=item C<new($start, $stop, $restart, $status, $config)>

Creates a new L<MysqlInstance::Methods> object.

In order: start command, stop command, restart command, status command, path to config file.

=item C<detect()>

Detects appropriate commands an creates a new L<MysqlInstance::Methods> object.

=back

=cut

package MysqlInstance;
use strict;
use warnings FATAL => 'all';
use IniFile;
use Carp;

use DBI;

sub new {
  my ($class, $mycnf, $methods)  = @_;
  my $self = {};
  $self->{mycnf}    = $mycnf;
  $self->{methods}  = $methods || MysqlInstance::Methods->detect();
  bless $self, $class;
  return $self;
}

sub stop {
  my ($self) = @_;
  system($self->{methods}->{stop}) >> 8;
}

sub start {
  my ($self) = @_;
  system($self->{methods}->{start}) >> 8;
}

sub restart {
  my ($self) = @_;
  system($self->{methods}->{restart}) >> 8;
}

sub status {
  my ($self) = @_;
  system($self->{methods}->{status}) >> 8;
}

sub config {
  my ($self) = @_;
  my $cfg = undef;
  eval {
    $cfg = {IniFile::read_config($self->{mycnf} || $self->{methods}->{config})};
  };
  if($@ or not defined $cfg) {
    die("Unable to open ".
          ($self->{mycnf} || $self->{methods}->{config})
            .": ". ($@ ? $@ : 'unknown reason'));
  }
  return $cfg;
}

sub methods {
  my ($self, $new_methods) = @_;
  my $old_methods = $self->{methods};
  $self->{methods} = $new_methods || $old_methods;
  return $old_methods;
}

sub remote {
use RObj;
  my ($class, $dsn, $action, @args) = @_;
  my $ro = RObj->new($dsn);
  $ro->add_package('IniFile');
  $ro->add_package('MysqlInstance::Methods');
  $ro->add_package('MysqlInstance');
  $ro->add_main(sub {
      my $act = shift;
      my $mi = MysqlInstance->new(@_);
      if($act eq 'stop') {
        return $mi->stop();
      }
      elsif($act eq 'start') {
        return $mi->start();
      }
      elsif($act eq 'restart') {
        return $mi->restart();
      }
      elsif($act eq 'status') {
        return $mi->status();
      }
      elsif($act eq 'config') {
        return $mi->config();
      }
    });
  return [$ro->do($action, @args)];
}

1;

=pod

=head1 NAME

MysqlInstance - Transparent local and remote control of mysqld

=head1 SYNOPSIS

MysqlInstance makes it easy to progmatically start, stop, restart, connect to, get the status or config of a mysqld instance.

  use MysqlInstance;
  
  # Manage a local instance
  my $l = MysqlInstance->new('localhost', '/etc/my.cnf');
  
  # and remote instances too.
  my $r = MysqlInstance->new('remotehost', '/etc/mysql/my.cnf', 'mysql', '~/.ssh/id_rsa');
  
  # Regardless, the interface is the same.
  $l->start();
  $r->start();
  
  $l->stop();
  $r->stop();

  # If the magic doesn't work
  my $m = MysqlInstance::Methods->new(
    start => '/usr/local/mysql/init start &>/dev/null',
    stop  => '/usr/local/mysql/init stop &>/dev/null',
    restart => '/usr/local/mysql/init restart &>/dev/null',
    status => '/usr/local/mysql/init status &>/dev/null'
    );
  $r->methods($m);

=head1 REQUIREMENTS

Needs the L<RObj>, L<IniFile>, L<DBI>, and L<DBD::mysql> packages.

Obviously, this package won't be much use unless it can also find an init script for mysql. See L<MAGIC> below for details on how one is found.

=head1 MAGIC

This module uses a L<MysqlInstance::Methods> object to determine how to start and start mysqld. 

=cut

