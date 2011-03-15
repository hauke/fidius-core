# FIDIUS Architecture

## Gems needed

Install these Rubygems:

- [`ai4r`](http://ai4r.rubyforge.org/)
- [`algorithms`](http://algorithms.rubyforge.org/)
- [`mysql2`](NO LINK FOUND YET)
- [`yard`](https://rubyforge.org/projects/yard/)

## Metasploit

You will need a copy of the open source
[Metasploit Framework](http://www.metasploit.com/framework/download/).
It is also possible (and recommended) to get a more recent SVN copy:

    $ svn co https://www.metasploit.com/svn/framework3/trunk/


## Configuration

You need to setup your configuration. To do so, edit the file
`config/fidius.yml.example` and it without the `.example` extension.

In that config file, you will find different sections:

- **`databases`** – This is an ActiveRecord configuration. Depending on
  the database adapter, different key/value pairs must be defined.
  - Currently, only a `development` subsection must be provided, **but
    this may change in future**.

- **`xmlrpc`** – This is the configuration for the architectures XMLRPC
   interface. You need to define these keys:
  - **`:host`** and **`:port`**: The XMLRPC server will user these keys
    to create and listen on a socket for incoming connections.
  - The FIDIUS Command&Control server will try to connect to this
    server, so that configuration should match these values.

- **`metasploit`** – This is the configuration for the interprocess
  communication between the architectures core and the Metasploit
  framework wrapper.
  - The keys **`:host`** and **`:port`** define the socket for the
    communication (you may change the values if you are concerned about
    an already used port).
  - With **`:path`**, you have to define the (full) path to your
    local Metasploit copy. This must point to the base path of the
    Metasploit framework (where the `msfconsole` et. al. are located).


## Start your engines

To run the FIDIUS environments, you need to follow these steps. (Note:
the servers may not act as "real" daemons, so you may run each of them
in a seperate terminal.)

1. Start the Metasploit framework daemon.

       $ ruby <path to fidius architecture>/bin/msfdrbd

2. Start the architectures XMLRPC interface.

       $ ruby <path to fidius architecture>/bin/xml_server.rb

3. Start the FIDIUS Command&Control server.

       $ cd <path to fidius c&c server>
       $ rails s

4. Go to [localhost:3000](http://localhost:3000/).

