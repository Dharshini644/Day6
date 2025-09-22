# Stage 1: Build with Gradle wrapper
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Copy Gradle wrapper and settings first (so dependencies can be cached)
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle settings.gradle ./

# Download dependencies (this will be cached unless build.gradle changes)
RUN ./gradlew --no-daemon dependencies || true

# Now copy source code
COPY src ./src

# Build the jar
RUN ./gradlew clean bootJar --no-daemon

# Stage 2: Run with JRE only
FROM eclipse-temurin:17-jre-focal
WORKDIR /app

# Copy the fat jar from builder
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
