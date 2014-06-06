define tomcat::config(
  $catalina_base = $::tomcat::catalina_home,
  $config_file = undef,
  $config_file_path = undef,
  $config_file_format = undef,
) {
  if $config_file {
    $_config_file = $config_file
  } else {
    $_config_file = $name
  }

  if $config_file_path {
    $_config_file_path = $config_file_path
  } else {
    $_config_file_path = "${catalina_base}/${_config_file}"
  }

  if $config_file_format {
    $_config_file_format = $config_file_format
  } else { 
    $_config_file_format = $_config_file ? {
      /*.properties$/ => 'properties',
      /*.xml$/        => 'xml',
      /*.sh$/         => 'sh',
      default         => undef
    }
  }
  
  validate_re( $_config_file_format, '^(properties|xml|sh)$',
  "${config_file_format} is not supported for config_file_format.
  Allowed values are 'properties', 'xml', and 'sh'.")

  concat { $_config_file_path:
    
  }
}
