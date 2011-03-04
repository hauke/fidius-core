# FIDIUS Architecture

## Gems needed

Install these Rubygems:

- [`ai4r`](http://ai4r.rubyforge.org/)
- [`algorithms`](http://algorithms.rubyforge.org/)


## Metasploit

You will need a copy of the open source [Metasploit Framework](http://www.metasploit.com/framework/download/).
It is also possible (and recommended) to get a more recent SVN copy:

    $ svn co https://www.metasploit.com/svn/framework3/trunk/


## Configuration files

You need to setup your configuration. To do so, edit these files and
save them without `.example` extension:

- `config/database.yml.example`
  - This is an ActiveRecord configuration.
  - Depending on the database adapter, different key/value pairs must be
    defined.
  - Currently, only a `development` section must be provided, **but this
    may change in future**.
- `config/rpc.yml.example`
  - This is the configuration file for the architectures XMLRPC
    interface. You need to define these keys:
  - **`:hostname`** and **`:port`**: The XMLRPC server will user these
    keys to create and listen on a socket for incoming connections.
  - The FIDIUS Command&Control server will try to connect to this
    server, so that configuration should match these values.
- `config/msf.yml.example`
  - This is the configuration for the interprocess communication between
    the architectures core and the Metasploit framework wrapper.
  - The keys **`:drb_host`** and **`:drb_port`** define the socket for
    the communication (you may change the values if you are concerned
    about an already used port).
  - With **`:msf_path`**, you have to define the (full) path to your
    local Metasploit copy. This must point to the base path of the
    Metasploit framework (where the `msfconsole` et. al. are located).
  

## Start your engines

To run the FIDIUS environments, you need to follow these step:

1. Start the Metasploit framework daemon.

       $ ruby <path to fidius architecture>/bin/msfdrbd

2. Start the architectures XMLRPC interface.

       $ ruby <path to fidius architecture>/bin/xml_server.rb

3. Start the FIDIUS Command&Control server.

       $ cd <path to fidius c&c server>
       $ rails s

4. Go to [localhost:3000](http://localhost:3000/).

