This is an example project that can be used to create the jar files needed for WAN Gateway. This project has 4 child modules: space, gateway, admin, feeder.

The space and gateway modules will create a processing unit jar for the space and gateway respectively.

The admin module contains code using the Gigaspaces Admin API to control the WAN Gateway.

The feeder module contains code to write sample data into a space.


The project also has 3 profiles: az, pa and tx. These profiles represent the artifacts needed for the 3 clusters or data centers. This is no longer used but could be used to set up a sample environment.

To build for the az cluster use:

`mvn package -Paz`

To build for the pa cluster use:

`mvn package -Ppa`

To build for the tx cluster use:

`mvn package -Ptx`

For more details about creating environment specific property files for Maven, see: https://maven.apache.org/guides/mini/guide-building-for-different-environments.html
