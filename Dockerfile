FROM tomcat:8.0
MAINTAINER mayurssoni@hotmail.com
EXPOSE 8080
COPY target/*.war /usr/local/tomcat/webapps/
