FROM openjdk:8-jdk-alpine
MAINTAINER Anders Asplund <anders.asplund@callistaenterprise.se>

ADD target/lightbulb-api-0.0.1-SNAPSHOT-jar-with-dependencies.jar lightbulb-api.jar

# Regarding settings of java.security.egd, see http://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom","-jar","/lightbulb-api.jar"]

EXPOSE 8080
