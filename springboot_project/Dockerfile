# Use Jetty base image with JDK 17
FROM jetty:11.0-jdk17

# Set the WAR file name
ENV WAR_FILE=petclinic1.war
EXPOSE 8080
# Copy the built WAR into Jetty's webapps as root.war
COPY ${WAR_FILE} /var/lib/jetty/webapps/root.war
