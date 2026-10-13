
# Stage 1: Build

FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Copy pom first to improve dependency caching
COPY pom.xml .

RUN mvn -B dependency:go-offline

COPY src ./src

RUN mvn -B -DskipTests clean package \
    && JAR_FILE="$(find target \
         -maxdepth 1 \
         -type f \
         -name '*.jar' \
         ! -name '*sources*' \
         ! -name '*javadoc*' \
         | head -n 1)" \
    && test -n "$JAR_FILE" \
    && cp "$JAR_FILE" /tmp/app.jar



# Stage 2: Runtime

FROM eclipse-temurin:17-jre-alpine

# curl is used by the health check
RUN apk add --no-cache curl \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=build --chown=appuser:appgroup \
     /tmp/app.jar /app/app.jar

USER appuser

EXPOSE 8080

ENV JAVA_TOOL_OPTIONS="\
-XX:MaxRAMPercentage=75.0 \
-XX:InitialRAMPercentage=25.0 \
-XX:+ExitOnOutOfMemoryError"

ENTRYPOINT ["java", "-jar", "/app/app.jar"]