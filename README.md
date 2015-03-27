#tomcat

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with tomcat](#setup)
    * [Beginning with tomcat](#beginning-with-tomcat)
4. [Usage - Configuration options and additional functionality](#usage)
    * [I want to install Tomcat from a specific source.](#i-want-to-install-tomcat-from-a-specific-source)
    * [I want to run multiple copies of Tomcat on a single node.](#i-want-to-run-multiple-copies-of-tomcat-on-a-single-node)
    * [I want to deploy WAR files.](#i-want-to-deploy-are-files)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Defined Types](#defined-types)
    * [Parameters](#parameters)
        - [tomcat](#tomcat-1)
        - [tomcat::config::server](#tomcatconfigserver)
        - [tomcat::config::server::connector](#tomcatconfigserverconnector)
        - [tomcat::config::server::context](#tomcatconfigservercontext)
        - [tomcat::config::server::engine](#tomcatconfigserverengine)
        - [tomcat::config::server::host](#tomcatconfigserverhost)
        - [tomcat::config::server::listener](#tomcatconfigserverlistener)
        - [tomcat::config::server::realm](#tomcatconfigserverrealm)
        - [tomcat::config::server::service](#tomcatconfigserverservice)
        - [tomcat::config::server::tomcat_users](#tomcatconfigservertomcat_users)
        - [tomcat::config::server::valve](#tomcatconfigservervalve)
        - [tomcat::instance](#tomcatinstance)
        - [tomcat::service](#tomcatservice)
        - [tomcat::setenv::entry](#tomcatsetenventry)
        - [tomcat::war](#tomcatwar)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
    * [Contributing](#contributing)
    * [Tests](#running-tests)

##Overview

The tomcat module enables you to install, deploy, and configure Tomcat web services.

##Module Description

Tomcat is a Java web service provider. The Puppet Labs module gives you a way to install multiple versions of Tomcat, as well as multiple copies of a version, and deploy web apps to it. The tomcat module also manages the Tomcat configuration file with Puppet.

##Setup

**NOTE: You must have Java installed in order to use this module. The version of Java needed will depend on the version of Tomcat you are installing. Older versions of Tomcat require >=java6, while the latest version of Tomcat needs >=java7.**

###Stdlib

This module requires puppetlabs-stdlib >= 4.0. On Puppet Enterprise, this upgrade must be completed manually before this module can be installed. To update stdlib, run:

```
puppet module upgrade puppetlabs-stdlib
```

###Beginning with tomcat

The simplest way to get Tomcat up and running with the tomcat module is to install the Tomcat package from EPEL,

```puppet
class { 'tomcat':
  install_from_source => false,
}
class { 'epel': }->
tomcat::instance{ 'default':
  package_name        => 'tomcat',
}->
```

and then start the service.

```puppet
tomcat::service { 'default':
  use_jsvc     => false,
  use_init     => true,
  service_name => 'tomcat',
}
```

##Usage

###I want to install Tomcat from a specific source.

To download Tomcat from a specific source and then start the service,

```puppet
class { 'tomcat': }
class { 'java': }
tomcat::instance { 'test':
  source_url => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz'
}->
tomcat::service { 'default': }
```

###I want to run multiple copies of Tomcat on a single node.

```puppet
class { 'tomcat': }
class { 'java': }

tomcat::instance { 'tomcat8':
  catalina_base => '/opt/apache-tomcat/tomcat8',
  source_url    => 'http://mirror.nexcess.net/apache/tomcat/tomcat-8/v8.0.8/bin/apache-tomcat-8.0.8.tar.gz'
}->
tomcat::service { 'default':
  catalina_base => '/opt/apache-tomcat/tomcat8',
}

tomcat::instance { 'tomcat6':
  source_url    => 'http://apache.mirror.quintex.com/tomcat/tomcat-6/v6.0.41/bin/apache-tomcat-6.0.41.tar.gz',
  catalina_base => '/opt/apache-tomcat/tomcat6',
}->
tomcat::config::server { 'tomcat6':
  catalina_base => '/opt/apache-tomcat/tomcat6',
  port          => '8105',
}->
tomcat::config::server::connector { 'tomcat6-http':
  catalina_base         => '/opt/apache-tomcat/tomcat6',
  port                  => '8180',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}->
tomcat::config::server::connector { 'tomcat6-ajp':
  catalina_base         => '/opt/apache-tomcat/tomcat6',
  port                  => '8109',
  protocol              => 'AJP/1.3',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}->
tomcat::service { 'tomcat6':
  catalina_base => '/opt/apache-tomcat/tomcat6'
```

###I want to deploy WAR files.

The name of the WAR must end with '.war'.

```puppet
tomcat::war { 'sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat8',
        war_source => '/opt/apache-tomcat/tomcat8/webapps/docs/appdev/sample/sample.war',
      }
```
The `war_source` can be a local file, puppet:/// file, http, or ftp.

###I want to change my configuration

Tomcat will not restart if its configuration changes unless you provide a `notify`.

For instance, to remove a connector, you would start with a manifest like this:

```puppet
tomcat::config::server::connector { 'tomcat8-jsvc':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '80',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '443'
        },
        connector_ensure => 'present'
}
```

Then you would set `connector_ensure` to 'absent', and provide `notify` for the service.

```puppet
tomcat::config::server::connector { 'tomcat8-jsvc':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '80',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '443'
        },
        connector_ensure => 'present'
        notify => Tomcat::Service['jsvc-default'],
}
```

##Reference

###Classes

####Public Classes

* `tomcat`: Main class, manages the installation and configuration of Tomcat.

####Private Classes

* `tomcat::params`: Manages Tomcat parameters.

###Defined Types

####Public Defined Types

* `tomcat::config::server`: Configures attributes for the [Server](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html) element in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::connector`: Configures [Connector](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html) elements in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::context`: Configures [Context](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html) elements in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::engine`: Configures [Engine](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Introduction) elements in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::host`: Configures [Host](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html) elements in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::listener`: Configures [Listener](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html) elements in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::realm`: Configures [Realm](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html) elements in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::service`: Configures a [Service](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html) element nested in the Server element in $CATALINA_BASE/conf/server.xml.
* `tomcat::config::server::tomcat_users`: Configures user and role elements for [UserDatabaseRealm] (http://tomcat.apache.org/tomcat-8.0-doc/realm-howto.html#UserDatabaseRealm) or [MemoryRealm] (http://tomcat.apache.org/tomcat-8.0-doc/realm-howto.html#MemoryRealm) in $CATALINA_BASE/conf/tomcat-users.xml or any other specified file.
* `tomcat::config::server::valve`: Configures a [Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html) element in $CATALINA_BASE/conf/server.xml.
* `tomcat::instance`: Installs a Tomcat instance.
* `tomcat::service`: Provides Tomcat service management.
* `tomcat::setenv::entry`: Adds an entry to the configuration file (ie. setenv.sh, /etc/sysconfig/tomcat, ...).
* `tomcat::war`:  Manages the deployment of WAR files.

####Private Defined Types

* `tomcat::instance::package`: Installs Tomcat from a package.
* `tomcat::instance::source`: Installs Tomcat from source.

###Parameters

####tomcat

#####`$catalina_home`

Specifies the base directory for the Tomcat installation.

#####`$user`

Sets the user to run Tomcat as.

#####`$group`

Sets the group to run Tomcat as.

#####`$install_from_source`

Specifies whether or not to install from source. A Boolean that defaults to 'true'.

#####`$purge_connectors`

Specifies whether or not to purge existing Connector elements from server.xml.

For example, if you specify an HTTP connector element using ```tomcat::config::server::connector``` and ```purge_connectors``` is set to ```true``` then existing HTTP connectors will be removed and only the HTTP connector you have specified will remain once the module has been applied.

This is useful if you want to change the ports of existing connectors instead of adding additional connectors. Boolean that defaults to 'false'.

#####`$purge_realms`

Specifies whether or not to purge existing Realm elements from server.xml.

For example, if you specify a Realm using ```tomcat::config::server::realm``` and ```purge_realms``` is set to ```true``` then existing Realm elements will be removed and only the Realm you have specified will remain once the module has been applied.

Boolean that defaults to 'false'.

#####`$manage_user`

Specifies whether or not to manage the user. Boolean that defaults to 'true'.

#####`$manage_group`

Specifies whether or not to manage the group. Boolean that defaults to 'true'.

####tomcat::config::server

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$class_name`

Specifies the Java class name of the implementation to use, and maps to the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) XML attribute in the Tomcat config file. This parameter is optional.

#####`$class_name_ensure`

Specifies whether to set or remove the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present', or 'absent'. Defaults to 'present'.

#####`$address`

Sets the TCP/IP address on which the server waits for a shutdown command, and maps to the [address](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) XML attribute. This parameter is optional.

#####`$address_ensure`

Specifies whether to set or remove the [address](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present', or 'absent'. Defaults to 'present'.

#####`$port`

Sets the port to wait for shutdown commands on.

#####`$shutdown`

Specifies the command that must be sent to `$port`.

#####`server_config`

Specifies where the server.xml should be, defaults to "${catalina_base}/config/server.xml"

####tomcat::config::server::connector

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$connector_ensure`

Specifies whether to add or remove ports that Tomcat will listen to for requests, and maps to the [Connector](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html) XML element. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$port`

Sets the TCP port number on which the Connector will create a server socket and await incoming connections. Maps to the [port](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes) XML attribute. Required unless `$connector_ensure` is set to 'false'.

#####`$protocol`

Sets the protocol to handle incoming traffic. Maps to the [protocol](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes) XML attribute. Defaults to '[name]' passed in the define.

#####`$parent_service`

Specifies the [Service](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Introduction) element this Connector should be nested
beneath. Defaults to 'Catalina'.

#####`$additional_attributes`

Specifies any additional attributes to add to the Connector. Should
be a hash of the format 'attribute' => 'value'. This parameter is optional.

#####`$attributes_to_remove`

Specifies any attributes to remove from the Connector. Should
be a hash of the format 'attribute' => 'value'. This parameter is optional.

####tomcat::config::server::context

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$context_ensure`

Specifies whether to add or remove Context XML element in configuration file. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$doc_base`
Specifies the Document Base or Context Root ([docBase] (http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Common_Attributes)) attribute for a web application.

#####`$parent_service`

Specifies the Service XML element this Context should be nested beneath. Defaults to 'Catalina'.

#####`$parent_engine`

Specifies which Engine element this Context should be nested beneath. Needs to be the `name` attribute for the Engine. Only valid if `$parent_host` is specified. 

#####`$parent_host`
Specifies the virtual host ([Host](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes) XML element) the Context should be nested beneath. Needs to be the `name` attribute for the Host. 

#####`$additional_attributes` 

Specifies any additional attributes to add to the Context. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

#####`$attributes_to_remove`

Specifies any attributes to remove from the Context. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

####tomcat::config::server::engine

#####`$default_host`

Specifies the default host name for the host that will process requests directed to host names on this server, but which are not configured in this configuration file. Maps to the [defaultHost](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute for the Engine. This parameter is required.

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$background_processor_delay`

Determines the delay (in seconds) between the invocation of the backgroundProcess method on this engine and its child containers. Maps to the [backgroundProcessorDelay](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. This parameter is optional.

#####`$background_processor_delay_ensure`

Specifies whether to add or remove the [backgroundProcessorDelay](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$class_name`

Specifies the Java class name of the implementation to use, and maps to the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute in the Tomcat config file. This parameter is optional.

#####`$class_name_ensure`

Specifies whether to add or remove the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$engine_name`

Specifies the logical name of the Engine, used in log and error messages. Maps to the [name](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. Defaults to '[name]' passed in the define.

#####`$jvm_route`

Specifies the identifier which must be used in load balancing scenarios to enable session affinity. Maps to the [jvmRoute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. This parameter is optional.

#####`$jvm_route_ensure`

Specifies whether to add or remove the [jvmRoute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$parent_service`

Specifies the Service element the Engine should be nested beneath. Defaults to 'Catalina'.

#####`$start_stop_threads`

Sets the number of threads the Engine will use to start child Host elements in parallel. Maps to the [startStopThreads](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. This parameter is optional.

#####`$start_stop_threads_ensure`

Specifies whether to add or remove the [startStopThreads](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present' and 'absent'. Defaults to 'present'.

####tomcat::config::server::host

#####`$app_base`

Specifies the Application Base directory for the virtual host, and maps to the [appBase](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes) XML attribute for the Host. This parameter is required
unless [`$host_ensure`](#host_ensure) is set to 'false' or 'absent'.

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$host_ensure`

Specifies whether to add or remove the virtual host, or [Host](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Introduction) element. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$host_name`

Specifies the the network name of the virtual host, as registered in your DNS server. Maps to the [name](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes) XML attribute for the Host. Defaults to '[name]' passed in the define.

#####`$parent_service`

Specifies the Service element the Host should be nested beneath. Defaults to 'Catalina'.

#####`$additional_attributes`

Specifies any additional attributes to add to the Host. Should
be a hash of the format 'attribute' => 'value'. This parameter is optional

#####`$attributes_to_remove`

Specifies any attributes to remove from the Host. Should
be an array of the format 'attribute' => 'value'. This parameter is optional.

####tomcat::config::server::listener

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$listener_ensure`

Specifies whether to add or remove Listener XML element in configuration file. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$class_name`

Specifies the Java class name of the implementation to use, and maps to the className XML attribute of a Listener Element. Defaults to '[name]' passed in the define.

#####`$parent_service`

Specifies the Service element this Listener should be nested beneath. Only valid if `$parent_engine` or `$parent_host` is specified. Defaults to 'Catalina' if `$parent_host` or `$parent_engine` is specified.

#####`$parent_engine`

Specifies which Engine element this Listener should be nested beneath. Needs to be the `name` attribute for the Engine.

#####`$parent_host`

Specifies which Host element this Listener should be nested beneath. Needs to be the `name` attribute for the Host.

#####`$additional_attributes`

Specifies any additional attributes to add to the Listener. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

#####`$attributes_to_remove`

Specifies any attributes to remove from the Listener. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

####tomcat::config::server::realm

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$class_name`

Specifies the Java class name of the Realm implementation to use. Maps to the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html#Common_Attributes) XML attribute. Defaults to '[name]' passed in the define.

#####`$realm_ensure`

Specifies whether to add or remove this Realm element in the configuration file. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$parent_service`

Specifies the Service element this Realm element should be nested beneath. Defaults to 'Catalina'.

#####`$parent_engine`

Specifies the Engine element this Realm should be nested beneath. Needs to be the `name` attribute for the desired Engine element. Defaults to 'Catalina'.

#####`$parent_host`

Specifies the Host element this Realm should be nested beneath. Needs to be the `name` attribute for the desired Host element. This parameter is optional.

#####`$parent_realm`

Specifies the Realm element this Realm should be nested beneath. Needs to be the `className` attribute for the desired Realm element. This parameter is optional.

#####`$additional_attributes`

Specifies any additional attributes to add to the Realm element. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

#####`$attributes_to_remove`

Specifies attributes to remove from the Realm element. Should be an array of attribute names. This parameter is optional.

####tomcat::config::server::service

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$class_name`

Specifies the Java class name of the implementation to use, and maps to the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes) XML attribute. This parameter is optional.

#####`$class_name_ensure`

Specifies whether to set or remove the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes) XML attribute. Valid values are 'true', 'false', 'present', or 'absent'. Defaults to 'present'.

#####`$service_ensure`

Specifies whether to add or remove the [Service](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Introduction) element. Valid values are 'true', 'false', 'present', or 'absent'. Defaults to 'present'.

####tomcat::config::server::tomcat_users

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$element`

Specifies the element type. Valid values are 'user' or 'role. Defaults to 'user'.

#####`$element_name`

Depending on the element it sets 'username' or 'rolename' to identify the $element. Defaults to $name.

#####`$ensure`

Specifies whether to add or remove the XML element in configuration file. Valid values are 'true', 'false', 'present', and 'absent'. Defaults to 'present'.

#####`$file`

Specifies the path to the file to manage. Must be fully qualified. Defaults to $CATALINA_BASE/conf/tomcat-users.xml.

#####`$manage_file`

Set $manage_file to true for managing the file. It sets file permission, owner, group and create a basic tomcat-users XML if file does not exist yet.

#####`$password`

Specifies the 'password' for 'user' elements.

#####`$roles`

Specifies the 'roles' for 'user' elements.

####tomcat::config::server::valve

#####`$catalina_base`

Specifies the root of the Tomcat installation.

#####`$class_name`

Specifies the Java class name of the implementation to use. Maps to the [className](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Logging/Attributes) XML attribute. Defaults to '[name]' passed in the define.

#####`$parent_host`

Specifies the virtual host ([Host](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes) XML element) the Valve should be nested beneath. If not specified, the Valve will be nested beneath the Engine under `$parent_service`.

#####`$parent_service`

Specifies is the Service element this Valve should be nested beneath. Defaults to 'Catalina'.

#####`$valve_ensure`

Specifies whether to add or remove the component that will be inserted into the request processing pipeline for the associated Catalina container. Maps to the  [Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Introduction) XML element. Valid values are 'true', 'false', 'present', or 'absent'. Defaults to 'present'.

#####`$additional_attributes`

Specifies any additional attributes to add to the Valve. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

#####`$attributes_to_remove`

Specifies any attributes to remove from the Valve. Should be a hash of the format 'attribute' => 'value'. This parameter is optional.

####tomcat::instance

#####`$catalina_home`

Specifies the root of the Tomcat installation. Only affects the instance installation if `$install_from_source` is true.

#####`$catalina_base`

Specifies the base directory for the Tomcat installation. Only affects the instance installation if `$install_from_source` is true.

#####`$install_from_source`

Specifies whether or not to install from source.

#####`$source_url`

Specifies the source URL to install from. Required if `$install_from_source` is true.

#####`$source_strip_first_dir`

Specifies whether or not to strip the first directory when unpacking the source tarball. A Boolean that defaults to 'true' when installing from source. Requires nanliu/staging > 0.4.0

#####`$package_ensure`

Specifies what the ensure should be set to in the package resource when installing from a package.

#####`$package_name`

Specifies the the name of the package you want to install. Required if `$install_from_source` is false.

####tomcat::service

#####`$catalina_home`

Specifies the root of the Tomcat installation.

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$use_jsvc`

Specifies whether or not to use Jsvc for service management. A Boolean that defaults to 'false'. If both `$use_jsvc` and `$use_init` are false,
`$CATALINA_BASE/bin/catalina.sh start` and `$CATALINA_BASE/bin/catalina.sh stop` are used for service management.

#####`$java_home`

Specifies the path Java is installed under. Only applies if `$use_jsvc = 'true'`

#####`$service_ensure`

Determines whether the Tomcat service is on or off. Valid values are 'running', 'stopped', 'true', and 'false'. (To determine whether the service is present/absent, see [tomcat::config::server::service](#tomcatconfigserverservice).)

#####`$service_enable`

Specifies whether to enable the Tomcat service at boot. Valid options are `true` or `false`. To use `$service_enable`, `use_init` must be set to `true`. If `$service_enable` is unset, `$use_init` is set to `true`, and `$service_ensure` is set to `running` or `true`, then `$service_enable` will be set to `true`.

#####`$use_init`

Specifies whether or not to use the package-provided init script for service management. A Boolean that defaults to 'false'. Note that the
tomcat module does not supply an init script, so setting `$use_init` to true will simply set up the service with an existing init script.
If both `$use_jsvc` and `$use_init` are false, `$CATALINA_BASE/bin/catalina.sh start` and `$CATALINA_BASE/bin/catalina.sh stop` are used
for service management.

#####`$service_name`

Specifies the name to use for the service when `$use_init` is 'true'.

#####`$start_command`

Sets the start command to use for the service.

#####`$stop_command`

Sets the stop command to use for the service.

####tomcat::setenv::entry

#####`$value`

Specifies the value of the parameter you're setting.  If array is passed, values are separated with a single space.

#####`$ensure`

Determines whether the fragment should be present or absent.

#####`$config_file`

Path to the configuration file to edit. Defaults to '$::tomcat::catalina_home/bin/setenv.sh'.

#####`$base_path`

Sets the path to create the setenv.sh script under. Should be either '$catalina_base/bin' or '$catalina_home/bin'. **Deprecated** This parameter is being deperecated, please use `$config_file`.

#####`$param`

Specifies the parameter you're setting. Defaults to '[name]' passed in the define.

#####`$quote_char`

Specifies the character with which to quote the value. This parameter is optional.

#####`$order`

Specifies the order to the parameter in the file ( Defaults to 10). This parameter is optional.

####tomcat::war

#####`$catalina_base`

Specifies the base directory for the Tomcat installation.

#####`$app_base`

Specifies the path relative to `$catalina_base` to deploy the WAR to. Defaults to 'webapps'.

#####`$deployment_path`

Specifies the path to deploy the WAR to. This parameter is optional. You may only specify either `$app_base` or `$deployment_path`, but not both..

#####`$war_ensure`

Specifies whether to add or remove the WAR. Valid values are 'present', 'absent', 'true', and 'false'. Defaults to 'present'.

#####`$war_name`

Specifies the name of the WAR. Must end in '.war'. Defaults to '[name]' passed in the define. This parameter is optional.

#####`$war_purge`

Specifies whether to purge the exploded WAR directory.  Boolean defaulting to true. This parameter is only applicable when `$war_ensure` is 'absent' or 'false'. Setting this parameter to false will not prevent Tomcat from removing the exploded WAR directory if Tomcat is running and autoDeploy is set to true.

#####`$war_source`

Specifies the source to deploy the WAR from. Currently supports http(s)://, puppet://, and ftp:// paths. `$war_source` must be specified unless `$war_ensure` is set to 'false' or 'absent'.

##Limitations

This module only supports Tomcat installations on \*nix systems.  The `tomcat::config::server*` defines require augeas >= 1.0.0.

###Stdlib

This module requires puppetlabs-stdlib >= 4.2.0. On Puppet Enterprise, this upgrade must be completed manually before this module can be installed. To update stdlib, run:

```
puppet module upgrade puppetlabs-stdlib
```

###Multiple Instances

If you are not installing Tomcat instances from source, depending on your packaging, multiple instances may not work.

##Development

###Contributing

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

###Running tests

This project contains tests for both [rspec-puppet](http://rspec-puppet.com/) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) to verify functionality. For in-depth information please see their respective documentation.

Quickstart:

    gem install bundler
    bundle install
    bundle exec rake spec
    bundle exec rspec spec/acceptance
    RS_DEBUG=yes bundle exec rspec spec/acceptance
