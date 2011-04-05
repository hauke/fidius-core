## Simulation
Instead of using /bin/xml_server and /bin/msfdrbd you can use the simulator
by specifying "databases:simulator" and "xmlrpc-simulator" as shown in config/fidius.yml.example.

By starting bin/xmlserver_simulator you will be able to use candc server completly without metasploit 
and real target machines.

You may need to setup the database for the simulator:

      $ rake db:create ENV=simulator
      $ rake db:migrate ENV=simulator

Use 
      $ rake scenario:setup ENV=simulator ID=001

to setup a test scenario.


