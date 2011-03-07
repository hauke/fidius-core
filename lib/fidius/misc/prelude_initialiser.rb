module FIDIUS
  module PreludeInitialiser
    FIDIUS.connect_db
    h = FIDIUS::Asset::Host.find_or_create_by_ip("10.20.20.1")
    h.os_name = "prelude"
    h.save
    FIDIUS.disconnect_db
  end
end
