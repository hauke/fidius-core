module FIDIUS
  module Server
    module Handler
      class Decision < FIDIUS::Server::Handler::Base

        def next_host
          result = FIDIUS::MachineLearning::AgendManager.instance.agent.next
          return result.id if result
          return -1
        end

        def reset_agent
          FIDIUS::MachineLearning::AgendManager.instance.reset
          ""
        end

        def pick_exploit interface_id, blacklist = nil
          inter = FIDIUS::Asset::Interface.find(interface_id)
          result = FIDIUS::ExploitPicker::exploit_for_interface inter, blacklist
          return result.name if result
          return ""
        end
      end
    end
  end
end
