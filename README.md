# Bonfire
The end goal is to have an peer to peer chat application framework which run on cryptographically signed javascript scripts.

## Scripts

There will be two types of scripts, manager scripts, and plugin scripts. 

### Manager

The manager scripts will use an api provided by bonfire to send and recieve message json objects. They will also do some basic
display of these message objects and manage the plugin scripts. In general the manager can do whatever it wants with the data.
I plan on the main purpose being chat applications, but in theory any type of application could be created.

### Plugin

The plugin scripts will simply be bits of code that could be called by the manager script. The functionality of the plugins
really depends on how the manager script decides to use them.
