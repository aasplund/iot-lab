FROM openjdk:8-jdk-alpine
MAINTAINER Anders Asplund <anders.asplund@callistaenterprise.se>

EXPOSE 8070

# Regarding settings of java.security.egd, see http://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source
#ENTRYPOINT ["java","-Dspring.profiles.active=docker","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
ENTRYPOINT ["/usr/bin/java", "-jar", "/usr/share/gunnebo/light-bulb.jar"]

ARG JAR_FILE
ADD target/${JAR_FILE} /usr/share/myservice/light-bulb.jar
#ADD target/light-bulb-rest-api-0.0.1-SNAPSHOT.jar app.jar
ADD target/lib           /usr/share/myservice/lib

