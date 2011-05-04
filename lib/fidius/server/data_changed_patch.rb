# This extension is for xml-rpc server to determine if data in database
# was changed.
# The C&C server can asks this, whether to reload things via AJAX.

module ActiveRecord
  class Base
  
    @@data_changed = true
    
    def self.data_changed?
      tmp = @@data_changed
      @@data_changed = false
      tmp
    end
    
    def data_changed!
      @@data_changed = true
    end

    after_create  :data_changed!
    after_save    :data_changed!
    after_destroy :data_changed!

  end # class Base
end # module ActiveRecord
