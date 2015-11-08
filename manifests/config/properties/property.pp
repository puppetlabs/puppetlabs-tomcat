## manage an entry for the properties file, typically catalina.properties
define tomcat::config::properties::property (
  $catalina_base,
  $value,
  $property = $name,
  $section  = 'default',
  $file     = 'conf/catalina.properties',
) {
  concat::fragment { "${section} ${property}":
    target  => "${catalina_base}/${file}",
    content => "${property}=${value}",
  }
}
