FROM maven as build
WORKDIR /app
COPY . .
RUN mvn install

# FROM tomcat:8.0-alpine
# COPY --from=build /app/target/Uber.jar /usr/local/tomcat/webapps/
# EXPOSE 8080
# CMD ["catalina.sh", "run"]

#select code + ctrl + / = comment all lines
FROM openjdk:11
WORKDIR /app
COPY --from=build /app/target/Uber.jar .
EXPOSE 9999
CMD ["java", "-jar", "Uber.jar"]
