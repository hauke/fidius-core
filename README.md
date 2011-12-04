# FIDIUS Architecture

## Architecture

The Fidius System consists of different components connected to each 
other. The main Component is the Fidius-Core provided in this package. 
On one side the Fidius C&C-Server GUI connects to the Core with an 
XML-RPC Interface. On the other side the Core connects to msfdrb Server 
which provides and DRb interface to msf. The msfdrb Server is also
provided in this package.

## Metasploit

You will need a copy of the open source
[Metasploit Framework](http://www.metasploit.com/framework/download/).
It is also possible (and recommended) to get a more recent git copy:

    $ git clone git://github.com/rapid7/metasploit-framework.git

## Configuration

You need to setup your configuration. To do so, edit the file
`config/fidius.yml`. There is an example configuration at 
`config/fidius.yml.example` and you should use that as a base for your
own configuration.
A full example configuration file is in `config/fidius.yml.example-full`

In that config file, you will find different sections:

- **`databases`** – This is an ActiveRecord configuration. Depending on
  the database adapter, different key/value pairs must be defined.
  - In normal use the `development` subsection is used as the general
    database for this program.
  - The section `evasiondb` is used to store the data from the Fidius EvasionDB.

- **`metasploit`** – This is the configuration for the interprocess
  communication between the architectures core and the Metasploit
  framework wrapper (msfdrb).
  - The keys **`:host`** and **`:port`** define the socket for the
    communication (you may change the values if you are concerned about
    an already used port).
  - With **`:path`**, you have to define the (full) path to your
    local Metasploit copy. This must point to the base path of the
    Metasploit framework (where the `msfconsole` et. al. are located).

- **`xmlrpc`** – This is the configuration for the architectures XMLRPC
   interface. You need to define these keys:
  - **`:host`** and **`:port`**: The XMLRPC server will user these keys
    to create and listen on a socket for incoming connections.
  - The FIDIUS Command&Control server will try to connect to this
    server, so that configuration should match these values.

- **`prelude`** – This is the configuration for the ids to test.
  - The key **`:host`** defines the IP address of the prelude host
    used in this network.

## Gems needed

Run bundle to install all required gems:

$ gem install bundler
$ bundle install

## Setup Database

The database must be setup before using this software.

       $ rake db:migrate

## Start your engines

To run the FIDIUS environments, you need to follow these steps. (Note:
the servers may not act as "real" daemons, so you may run each of them
in a separate terminal.)

1. Start the Metasploit framework daemon.

       $ ./bin/msfdrbd start

2. Start the architectures XMLRPC interface.

       $ ./bin/xmlserver start

3. Start the FIDIUS Command&Control server.

       $ cd <path to fidius c&c server>
       $ rails s

4. Go to [localhost:3000](http://localhost:3000/).

