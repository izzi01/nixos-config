#!/bin/sh -e

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo "${YELLOW}Making scripts in apps folder executable...${NC}"

# Find all files in apps folder and make them executable
if [ -d "apps" ]; then
    find apps -type f -exec chmod +x {} \;
    echo "${GREEN}All scripts in apps folder are now executable!${NC}"
else
    echo "${RED}apps folder not found!${NC}"
    exit 1
fi