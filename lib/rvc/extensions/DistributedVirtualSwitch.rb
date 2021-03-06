# Copyright (c) 2011 VMware, Inc.  All Rights Reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

class RbVmomi::VIM::DistributedVirtualSwitch
  def display_info
    config, = collect(:config)
    puts "name: #{config.name}"
    puts "description: #{config.description}"
    puts "product: #{config.productInfo.vendor} #{config.productInfo.name} #{config.productInfo.version}"
    puts "ports: #{config.numPorts}"
    puts "standalone ports: #{config.numStandalonePorts}"
    puts "maximum ports: #{config.maxPorts}"
    puts "netIORM: #{config.networkResourceManagementEnabled}"
  end

  def summarize
    t = table(['portgroup name', 'num ports', 'vlan', 'resource pool'])
    self.portgroup.each { |pg|
      vlanconfig = pg.config.defaultPortConfig.vlan
      case vlanconfig.class
      when RbVmomi::VIM::VmwareDistributedVirtualSwitchVlanIdSpec
        vlan = if vlanconfig.vlanId != 0 then vlanconfig.vlanId else "-" end
      when RbVmomi::VIM::VmwareDistributedVirtualSwitchTrunkVlanSpec
        vlan = vlanconfig.vlanId.map { |range|
          "#{range.start}-#{range.end}" }.join(',')
      end

      respool = pg.config.defaultPortConfig.networkResourcePoolKey.value
      if respool == "-1"
        respool = "-"
      else
        respool = self.networkResourcePool.find_all { |pool|
          respool == pool.key
        }[0].name
      end

      t << [pg.config.name, pg.config.numPorts, vlan, respool]
    }
    puts t
  end

  def children
    hash = {}
    self.portgroup.each { |pg|
      hash[pg.name] = pg
    }
    hash
  end

  #def self.ls_properties
  #  %w(name summary.description)
  #end

  def ls_text r
    " (vds)"
  end
end
