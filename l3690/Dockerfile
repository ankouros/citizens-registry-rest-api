# =========================
# Stage 1: Build (multi-module)
# =========================
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /build

# copy root pom + modules
COPY pom.xml .
COPY citizen-domain/pom.xml citizen-domain/pom.xml
COPY citizen-service/pom.xml citizen-service/pom.xml
COPY citizen-client/pom.xml citizen-client/pom.xml
COPY citizen-it/pom.xml citizen-it/pom.xml

# download deps
RUN mvn -B -pl citizen-service -am dependency:go-offline

# copy sources
COPY citizen-domain citizen-domain
COPY citizen-service citizen-service

# build only the service (and its deps)
RUN mvn -B -pl citizen-service -am clean package -DskipTests

# =========================
# Stage 2: Runtime
# =========================
FROM eclipse-temurin:21-jre-jammy

RUN useradd -m -u 10001 appuser
WORKDIR /app

COPY --from=build /build/citizen-service/target/*jar app.jar

EXPOSE 8080
USER appuser
ENTRYPOINT ["java","-jar","app.jar"]
