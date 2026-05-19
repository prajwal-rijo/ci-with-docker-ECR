FROM tomcat:9-jdk17

COPY target/hello-devops.war /usr/local/tomcat/webapps/

EXPOSE 8080
