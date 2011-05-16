module FIDIUS
  module Server
    module Handler
      class Base
        def rpc_method_finish(result="ok")
          #rpc_method_ended
          result.to_s
        end

      end
    end
  end
end
