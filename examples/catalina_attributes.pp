define tomcat::config::example (
  $catalina_base     = '/tmp',
  Boolean $show_diff = true,
){
include ::tomcat
}
