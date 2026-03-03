# --- Stage 1: Build Environment ---
FROM ghcr.io/cirruslabs/flutter:stable AS build

# වැඩ කරන ෆෝල්ඩරය
WORKDIR /app

# ව්‍යාපෘතියේ ගොනු පිටපත් කිරීම
COPY . .

# Dependencies ලබා ගැනීම
RUN flutter pub get

# Web එක සඳහා Build කිරීම
RUN flutter build web --release

# --- Stage 2: Production Environment (Nginx) ---
FROM nginx:alpine

# Nginx හි default html ෆෝල්ඩරයට අපේ build එක පිටපත් කිරීම
COPY --from=build /app/build/web /usr/share/nginx/html

# Nginx සාමාන්‍යයෙන් දුවන්නේ Port 80 හි
EXPOSE 80

# Nginx ධාවනය කිරීම
CMD ["nginx", "-g", "daemon off;"]