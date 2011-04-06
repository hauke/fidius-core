module FIDIUS
  module Loudness

    SILENT = 0
    VERY_VERY_LOUD = 100

=begin
    def self.<
        raise NotImplementedError, "not implemented yet"
    end

    def self.>
        raise NotImplementedError, "not implemented yet"
    end
=end

    # Returns the lodness of this action on the attacked host. If this is null
    # no HIDS or virus protection programm will recognize this.
    #
    # @return [int]
    def get_loudness_host
      raise NotImplementedError, "method must be overwritten by subclass"
    end

    # Returns the lodness of this action on the network. If this is null
    # no NIDS will recognize this.
    #
    # @return [int]
    def get_loudness_net
      raise NotImplementedError, "method must be overwritten by subclass"
    end

  end # module Loudness
end # module FIDIUS
