#!/bin/bash
set -e

echo "=== Flutter Web Build Script for Vercel ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Check and install Flutter
echo -e "${YELLOW}[1/5] Checking Flutter SDK...${NC}"
if [ ! -d "flutter" ]; then
  echo "Flutter not found. Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable
  export PATH="$PATH:$(pwd)/flutter/bin"
else
  echo "Flutter found. Updating..."
  cd flutter
  git pull
  cd ..
  export PATH="$PATH:$(pwd)/flutter/bin"
fi

# 2. Run Flutter doctor
echo -e "${YELLOW}[2/5] Running Flutter doctor...${NC}"
./flutter/bin/flutter doctor || true

# 3. Enable web support
echo -e "${YELLOW}[3/5] Enabling Flutter web support...${NC}"
./flutter/bin/flutter config --enable-web

# 4. Get dependencies
echo -e "${YELLOW}[4/5] Fetching dependencies...${NC}"
./flutter/bin/flutter pub get

# 5. Build for web
echo -e "${YELLOW}[5/5] Building Flutter web application...${NC}"
./flutter/bin/flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

echo -e "${GREEN}=== Build completed successfully! ===${NC}"
echo -e "${GREEN}Output directory: build/web${NC}"
