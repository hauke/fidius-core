module FIDIUS
  module Server
    module Handler
      class Model < FIDIUS::Server::Handler::Base
        def clean_hosts
          FIDIUS::Asset::Host.destroy_all
          FIDIUS::UserDialog.create_dialog("Removed all Hosts","All Hosts were removed")
          rpc_method_finish
        end

        def find(opts)
          # moved establish connection here to avoid
          # this nasty RuntimeError: Uncaught exception timeout is not implemented yet in method model.find(2)
          # which is triggered by active_record/connection_adapters/abstract/connection_pool.rb:checkout wait method
          # in ruby 1.9 wait(timeout = nil) waiting for timeout is not implemented... strange ?!
          # UPDATE: connect_db moved to rpc_method_began
          #rpc_method_began

          raise XMLRPC::FaultException.new(1, "model.find expects at least 2 parameters(modelname, opts)") if opts.size < 2
          model_name = opts.shift
          opts = ActiveSupport::JSON.decode(opts[0])
          res = nil
          model = nil

          begin
            # search model global
            model = nil
            model_name.split("::").each do |const|
              unless model
                model = Kernel.const_get(const)
              else
                model = model.const_get(const)
              end
            end

          rescue
          end          
          begin
            # search model in FIDIUS namespace
            model = Kernel.const_get("FIDIUS").const_get(model_name)
          rescue
          end
          begin
            # search model in FIDIUS::Asset namespace
            model = Kernel.const_get("FIDIUS").const_get("Asset").const_get(model_name)
          rescue
          end
          raise XMLRPC::FaultException.new(2, "Class #{model_name} was not found") unless model
          begin #save execution of find method
            res = model.find(*opts)
          rescue
            # doesnt matter, object not found will be thrown
          end
          unless res
            raise XMLRPC::FaultException.new(3, "object was not found")
          end

          # see above nasty timeout is not implemented error
          rpc_method_finish(res.to_xml)
        end
      end
    end
  end
end 
