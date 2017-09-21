FROM openjdk:8-jdk-alpine
MAINTAINER Anders Asplund <anders.asplund@callistaenterprise.se>

EXPOSE 8080

ADD ./target/thing-0.0.1-SNAPSHOT.jar app.jar
#ADD src/main/resources/truststore.jks truststore.jks

# Regarding settings of java.security.egd, see http://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source
ENTRYPOINT ["java","-Dspring.profiles.active=docker","-Djavax.net.ssl.trustStore=truststore.jks","-Djavax.net.ssl.trustStorePassword=password","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
