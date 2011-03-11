module FIDIUS
  class Session < ActiveRecord::Base
    belongs_to :host, :class_name => "FIDIUS::Asset::Host"

  end # class Session
end # module FIDIUS
