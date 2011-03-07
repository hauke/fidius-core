# this extension is for xml-rpc server to determine
# if data in database was changed.
# candc can ask this, to reload things via ajax
module ActiveRecord
  class Base
    @@data_changed = true
    def self.data_changed?
      tmp = @@data_changed
      @@data_changed = false
      tmp
    end

    after_create do
      @@data_changed = true
    end
    after_save do
      @@data_changed = true
    end
    after_destroy do
      @@data_changed = true
    end

  end
end
