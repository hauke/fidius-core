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

      end
    end
  end
end
