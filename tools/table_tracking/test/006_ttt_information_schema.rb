# 006_ttt_information_schema.rb
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

require 'ttt/db'
require 'ttt/information_schema'
require 'test/lib/test_db'
require 'yaml'

describe TTT::InformationSchema do
  include TestDbHelper
  before :all do
    test_connect
    test_connect_is('localhost')
  end
  after :all do
    test_cleanup
  end
  it "should throw Exception on find()" do
    caught_excep=false
    begin
      InformationSchema.find(:all)
    rescue Exception
      caught_excep=true
    end
    caught_excep.should == true
  end
end

describe TTT::TABLE do
  include TestDbHelper
  before :all do
    test_connect
    test_connect_is('localhost')
    test_migration(CreateTestDataTable)
  end
  after :all do
    test_cleanup
  end
  it "should throw Exception on find()" do
    caught_excep=false
    begin
      TTT::TABLE.find(:all)
    rescue Exception
      caught_excep=true
    end
    caught_excep.should == true
  end

  it "should find `information_schema`.`TABLES` table" do
    TTT::TABLE.get('information_schema', 'TABLES').class.should == TTT::TABLE
  end

  {:name => 'TABLES', :engine => 'MEMORY', :table_type => 'SYSTEM VIEW'}.each do |k,v|
    it "`information_schema`.`TABLES` table #{k} should be #{v}" do
      TTT::TABLE.get('information_schema','TABLES').send(k).should == v
    end
  end


  it "all should find `test`.`test_data`" do
    TTT::TABLE.all.any? { |t| t.schema == "test" and t.name == "test_data" }.should == true
  end

  {
    :collation      => 'utf8_general_ci',
    :engine         => 'InnoDB',
    :table_type     => 'BASE TABLE',
    :rows           => 0,
    :comment        => '',
    :auto_increment => 1,
    :frm_version    => 10,
    :row_format     => 'Compact',
    :create_syntax  => "CREATE TABLE `test_data` (\n  `id` int(11) NOT NULL AUTO_INCREMENT,\n  `name` varchar(5) DEFAULT NULL,\n  `value` varchar(20) DEFAULT NULL,\n  PRIMARY KEY (`id`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8",
    :checksum       => nil,
    :check_time     => nil,
    :data_length    => 16384,
    :index_length   => 0,
    :data_free      => 4194304
  }.each do |k,v|
    it "`test`.`test_data` should #{k} == '#{v ? v : 'nil'}'" do
      TTT::TABLE.get('test','test_data').send(k).should == v
    end
  end

end
