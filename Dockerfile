# ---------- Base image with Java, Maven, and Python ----------
# We start from a base image with Java 17 and Maven
FROM eclipse-temurin:17-jdk

# Install Python, pip, and other necessary build dependencies
# We also install 'python3-venv' to ensure we can create a virtual environment
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv maven build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the primary working directory for the application
WORKDIR /app

# Copy the backend and ML API code into the container
COPY fake-news-detector-backend ./backend
COPY ml-api ./ml-api

# Create a Python virtual environment to manage dependencies
# This is the key change to solve the "externally-managed-environment" error
RUN python3 -m venv /opt/venv

# Make the virtual environment's binaries available in the PATH
ENV PATH="/opt/venv/bin:$PATH"

# Now, install Python dependencies into the isolated virtual environment
# We no longer need to specify 'pip3' since 'pip' is now on the PATH
RUN pip install --no-cache-dir -r ml-api/requirements.txt

# Pre-download Maven dependencies for the backend to speed up future builds
WORKDIR /app/backend
RUN mvn dependency:go-offline

# Expose the ports for the backend (8080) and the ML API (5000)
EXPOSE 8080 5000

# Start both the Java backend and the Python ML API in the background
# We explicitly call the Python interpreter from the virtual environment
CMD sh -c "cd /app/backend && mvn spring-boot:run & cd /app/ml-api && python3 app.py"
