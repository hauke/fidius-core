class FIDIUS::Asset::Host
  def add_interace(opts,&block)
    interface = FIDIUS::Asset::Interface.create(opts)
    self.interfaces << interface
    self.save
    block.call(interface)
  end

  def add_reachable_host(opts, &block)
    h = FIDIUS::Asset::Host.new(opts)
    h.pivot_host_id = self.id
    h.save
    block.call(h)
  end 
end

class FIDIUS::Asset::Interface
  def add_service(port,name,proto="tcp",info=nil)
    self.services << FIDIUS::Service.create(:port=>port,:name=>name,:proto=>proto,:info=>info)
    self.save
  end
end
