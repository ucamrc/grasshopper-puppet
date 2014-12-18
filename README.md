# Grasshopper Event Engine

Puppet configuration and environment management for the Grasshopper event engine.

## Environments

 * The app server logs can be found at /opt/grasshopper/server.log
 * If you make changes to the backend code you will need to restart the app server. This can be done by ssh'ing into the client machine by running `service grasshopper restart`.
 * Even if you'd install all the components on your host OS, you would not be able to run the server as some of the npm modules are compiled during the provisioning step.

### Development

### QA
