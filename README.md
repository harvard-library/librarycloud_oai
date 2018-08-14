Librarycloud OAI-PMH Data Provider
============

Description
-----------

An OAI-PMH data provider written in grails for the Librarycloud API.


Code Repository
---------------

[GitHub repo](https://github.com/harvard-library/librarycloud_oai).

Requirements
------------

* Grails (tested on v3.0.4)
* Groovy (tested in 2.4.4)

Setup
-----

* Create gradle.properties based in gradle.properties.example
* Edit application.yml development/test/production enviroment urls if not running oai on the same server / tomcat as librarycloud

Run
-----

As grails app:
* "./gradlew (-Dgrails.env=production) run" (if env not specified, runs in dev)

As war:
* "./gradlew (-Dgrails.env=production) war"
* deploy ./war/oai.war to tomcat
