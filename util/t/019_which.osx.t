# 019_which.osx.t
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
use Test::More tests => 4;

BEGIN {
  use_ok('Which');
}

SKIP: {
  skip 'Only relevant on OSX', 3 unless( -d "/System/Library/Frameworks" );
  is(Which::which('launchctl'), '/bin/launchctl', "finds launchctl");
  is(Which::which('/bin/bash'), '/bin/bash', "finds /bin/bash from absolute path");
  is(Which::which('not-real'), undef, "does not find not-real");
}
