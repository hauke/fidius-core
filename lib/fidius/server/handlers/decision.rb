module FIDIUS
  module Server
    module Handler
      class Decision < FIDIUS::Server::Handler::Base
        
        def next_host
          result = FIDIUS::MachineLearning::AgendManager.instance.agent.next
          return result.id if result
          return -1
        end

      end
    end
  end
end
