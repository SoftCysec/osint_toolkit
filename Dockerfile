# Stage 1: Build the frontend
FROM node:alpine AS frontend-build
WORKDIR /app/frontend
# Since there's no package-lock.json, we only copy package.json
COPY frontend/package.json ./
RUN npm install --silent
# Ensure this version matches your project's requirements
RUN npm install react-scripts@5.0.0 --silent 
COPY frontend/ .
RUN npm run build

# Stage 2: Build the backend
FROM python:latest AS backend-build
WORKDIR /app/backend
COPY backend/requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt
COPY backend/ .

# Prepare the static files from frontend to be served by backend
# Adjust the target directory according to your backend's static files configuration
COPY --from=frontend-build /app/frontend/build /app/backend/static

# Stage 3: Final image for deployment
FROM python:slim
WORKDIR /app
COPY --from=backend-build /app/backend /app

# Expose the backend port
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
