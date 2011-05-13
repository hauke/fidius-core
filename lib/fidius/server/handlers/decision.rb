        def decision.nn.next(opts)
          res = FIDIUS::MachineLearning.agent.next.id
          FIDIUS::UserDialog.create_yes_no_dialog("Next Target","KI choosed target. Want to attack this host?")
          rpc_method_finish(res)
        end

        # TODO REFACTOR THIS
        add_handler("decision.nn.train") do |opts|
          rpc_method_began
          unless $trained
            instances = Array.new
            FIDIUS::Asset::Interface.all.each do |host|
              instances << Instance.new(host, rand(10))
            end
            FIDIUS::MachineLearning.agent.train(instances, 100)
            $trained = true
          end
          rpc_method_finish
        end

