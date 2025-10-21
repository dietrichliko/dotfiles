#!/usr/bin/env bash
# ----------------------------------------------------------
# check-grid-cert.sh
# Verify usercert.pem and userkey.pem for Grid usage
# ----------------------------------------------------------

CERT=${1:-$HOME/.globus/usercert.pem}
KEY=${2:-$HOME/.globus/userkey.pem}
CA_PATH=${CA_PATH:-/etc/grid-security/certificates}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

# --- 1. Check files ---
if [[ ! -f "$CERT" ]]; then
  echo -e "${RED}❌ Certificate not found: $CERT${NC}"
  exit 1
fi
if [[ ! -f "$KEY" ]]; then
  echo -e "${RED}❌ Key not found: $KEY${NC}"
  exit 1
fi

# --- 2. Check matching key/cert ---
MOD_CERT=$(openssl x509 -noout -modulus -in "$CERT" | openssl md5)
MOD_KEY=$(openssl rsa  -noout -modulus -in "$KEY"  | openssl md5)

if [[ "$MOD_CERT" != "$MOD_KEY" ]]; then
  echo -e "${RED}❌ Certificate and key do NOT match${NC}"
  exit 1
else
  echo -e "${GREEN}✅ Certificate and key match${NC}"
fi

# --- 3. Show certificate info ---
echo "----------------------------------------"
openssl x509 -in "$CERT" -noout -subject -issuer -dates
echo "----------------------------------------"

# --- 4. Expiry check ---
EXPIRY_DATE=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null || date -jf "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s)
NOW=$(date +%s)
if (( EXPIRY_EPOCH < NOW )); then
  echo -e "${RED}❌ Certificate has EXPIRED${NC}"
else
  DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW) / 86400 ))
  echo -e "${GREEN}✅ Certificate is valid for another $DAYS_LEFT days${NC}"
fi

# --- 5. Chain verification ---
if [[ -d "$CA_PATH" ]]; then
  echo "Verifying trust chain with CA path: $CA_PATH"
  openssl verify -CApath "$CA_PATH" "$CERT"
else
  echo -e "${YELLOW}⚠️  CA path not found: $CA_PATH — skipping chain check${NC}"
fi

echo "Done."

