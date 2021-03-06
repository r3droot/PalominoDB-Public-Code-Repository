# empty.rb
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

Then /^validate raises SemanticsError with type (\w+)$/ do |type|
  no_exception=true
  begin
  @dsn.validate
  rescue Exception => e
    no_exception=false
    unless e.class == Pdb::SemanticsError
      raise
    end
    unless e.type == type.to_sym
      raise e, "Must be of #{type} type. Got: #{e.type}"
    end
  end
  raise Exception, "Did not catch SemanticsError with type #{type}" if no_exception
end
