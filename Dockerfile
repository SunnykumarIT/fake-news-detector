# ---------- Base image with Java, Maven, and Python ----------
FROM eclipse-temurin:17-jdk

# Install Python and Maven
RUN apt-get update && \
    apt-get install -y python python-pip maven && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy backend code
COPY fake-news-detector-backend ./backend

# Copy ML API code
COPY ml-api ./ml-api

# Install Python dependencies
RUN pip3 install --no-cache-dir -r ml-api/requirements.txt

# Pre-download Maven dependencies for backend
WORKDIR /app/backend
RUN mvn dependency:go-offline

# Expose ports (Backend: 8080, ML API: 5000)
EXPOSE 8080 5000

# Start both services together
CMD sh -c "cd /app/backend && mvn spring-boot:run & cd /app/ml-api && python app.py"