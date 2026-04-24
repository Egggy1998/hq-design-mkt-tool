#!/bin/bash
# 3D Vietnam Marketing System - Quick Setup
# Run: bash setup.sh
# 
# Setup n8n credentials (Baserow tables created MANUALLY on Baserow UI)

set -e

echo "
╔═══════════════════════════════════════════════════════════════╗
║     3D VIETNAM MARKETING SYSTEM - SETUP TOOL                  ║
║     Setup n8n + Facebook + Skills                            ║
╚═══════════════════════════════════════════════════════════════╝
"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Read input
echo ""
echo "📝 NHẬP THÔNG TIN CẦN THIẾT"
echo "============================================"
read -p "1. n8n Instance URL (VD: https://jqqpar.ezn8n.com): " N8N_URL
read -p "2. n8n Webhook ID: " N8N_WEBHOOK_ID
read -p "3. Facebook Page ID: " FB_PAGE_ID
read -p "4. Facebook Page Token: " FB_PAGE_TOKEN
read -p "5. Tên Business (VD: 3D Vietnam): " BUSINESS_NAME

WORKSPACE="$HOME/.openclaw/workspace"
SKILLS_DIR="$WORKSPACE/skills"

# Create directories
echo ""
warn "Tạo thư mục..."
mkdir -p "$WORKSPACE/memory"
mkdir -p "$SKILLS_DIR/facebook-page-manager"
log "Thư mục OK"

# Clone skills repo
echo ""
warn "Clone skills repo..."
if [ ! -d "$SKILLS_DIR/fullstack-mkt-skills" ]; then
    git clone https://github.com/minhnv0807/fullstack-mkt-skills.git "$SKILLS_DIR/fullstack-mkt-skills" 2>/dev/null || warn "Clone failed (skip)"
else
    warn "Skills repo đã tồn tại"
fi

# Create TOOLS.md
echo ""
warn "Tạo TOOLS.md..."
cat > "$WORKSPACE/TOOLS.md" << EOF
# TOOLS.md - ${BUSINESS_NAME}

## n8n
- **Instance**: ${N8N_URL}
- **Webhook ID**: ${N8N_WEBHOOK_ID}
- **Webhook URL**: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## Facebook
- **Page ID**: ${FB_PAGE_ID}
- **Token**: ${FB_PAGE_TOKEN}

## FRIDAYAI (Claude)
- **API Key**: sk-e2cc849b6212823af9af349bf58ee75229ee3cb71812925f8d8f339cc8aa9079
- **Endpoint**: https://oneai.fridayai.com/v1
EOF
log "TOOLS.md OK"

# Create tokens.json
echo ""
warn "Tạo tokens.json..."
cat > "$SKILLS_DIR/facebook-page-manager/tokens.json" << EOF
{
  "pages": {
    "${FB_PAGE_ID}": {
      "name": "${BUSINESS_NAME}",
      "token": "${FB_PAGE_TOKEN}"
    }
  }
}
EOF
log "tokens.json OK"

# Create PLAYBOOK.md
echo ""
warn "Tạo PLAYBOOK.md..."
cat > "$WORKSPACE/PLAYBOOK.md" << EOF
# CLAW MARKETING SYSTEM - Playbook

## 1. Concept
AI Marketing Agent cho spa/beauty equipment - ${BUSINESS_NAME}

## 2. Tech Stack
| Service | Notes |
|---------|-------|
| n8n | ${N8N_URL} - SA Designer workflow |
| Facebook | ${FB_PAGE_ID} |

## 3. n8n Webhook
- URL: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## 4. Daily Workflow
1. Content (SA3) → Import Baserow (Table: {CONTENT_TABLE_ID})
2. Design (n8n) → Webhook → Update "Link ảnh đã thiết kế"
3. Post (SA4) → Facebook Schedule → Update "Trạng thái" = Done

## 5. Baserow Tables (CREATED MANUALLY)
### Content Calendar (ID: {CONTENT_TABLE_ID})
| Field | Type |
|-------|------|
| Ngày đăng | date |
| Kênh đăng | single_select |
| Tiêu đề ngắn | text |
| Content bài đăng | long_text |
| Link ảnh đã thiết kế | text |
| Trạng thái | single_select |
| Ghi chú | text |

### Product Database (ID: {PRODUCT_TABLE_ID})
| Field | Type |
|-------|------|
| Tên thiết bị | text |
| Link ảnh | url |
| Link sản phẩm | url |

## 6. Troubleshooting
| Issue | Solution |
|-------|----------|
| FB token expired | Get new from Graph API Explorer |
| Baserow 404 | Use api.baserow.io (no /v1/) |
EOF
log "PLAYBOOK.md OK"

# Test Facebook
echo ""
warn "Test Facebook..."
echo -n "  Facebook: "
if curl -s "https://graph.facebook.com/v19.0/$FB_PAGE_ID?access_token=$FB_PAGE_TOKEN" | grep -q "name"; then
    log "OK"
else
    error "FAILED"
fi

echo "
╔═══════════════════════════════════════════════════════════════╗
║                 ✅ SETUP HOÀN THÀNH                          ║
╠═══════════════════════════════════════════════════════════════╣
║  FILES CREATED:                                               ║
║    - ~/.openclaw/workspace/TOOLS.md                          ║
║    - ~/.openclaw/workspace/PLAYBOOK.md                       ║
║    - ~/.openclaw/workspace/skills/fullstack-mkt-skills/     ║
║    - ~/.openclaw/workspace/skills/facebook-page-manager/    ║
║      tokens.json                                             ║
╠═══════════════════════════════════════════════════════════════╣
║  NEXT STEPS:                                                  ║
║    1. Create Baserow tables MANUALLY on Baserow UI           ║
║    2. Import n8n workflow (SA Designer Fixed)               ║
║    3. Test full workflow                                     ║
╚═══════════════════════════════════════════════════════════════╝
"
