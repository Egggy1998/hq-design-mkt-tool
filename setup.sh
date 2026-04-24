#!/bin/bash
# 3D Vietnam Marketing System - Quick Setup
# Run: bash setup.sh
# 
# Setup n8n + Facebook + Skills
# Skills are included in repo, copied to workspace on setup

set -e

echo "
╔═══════════════════════════════════════════════════════════════╗
║     3D VIETNAM MARKETING SYSTEM - SETUP TOOL                    ║
║     Setup n8n + Facebook + OpenClaw Skills                    ║
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create directories
echo ""
warn "Tạo thư mục..."
mkdir -p "$WORKSPACE/memory"
mkdir -p "$SKILLS_DIR"
log "Thư mục OK"

# Copy OpenClaw Skills từ repo (skills/ folder trong repo)
echo ""
warn "Copy OpenClaw Skills vào workspace..."

SKILLS_TO_COPY="content-writer marketing-planner facebook-page-manager baserow-integration image-designer social-media-manager n8n-workflow-engineering"

for skill in $SKILLS_TO_COPY; do
    if [ -d "$SCRIPT_DIR/skills/$skill" ]; then
        if [ ! -d "$SKILLS_DIR/$skill" ]; then
            cp -r "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/"
            log "Copied: $skill"
        else
            warn "Skill đã tồn tại: $skill"
        fi
    else
        warn "Skill không tìm thấy trong repo: $skill"
    fi
done

# Clone fullstack-mkt repo (MKT knowledge - BONUS)
echo ""
warn "Clone fullstack-mkt repo (MKT knowledge - BONUS)..."
if [ ! -d "$SKILLS_DIR/fullstack-mkt" ]; then
    git clone https://github.com/minhnv0807/fullstack-mkt-skills.git "$SKILLS_DIR/fullstack-mkt" 2>/dev/null || warn "Clone failed (skip)"
else
    warn "fullstack-mkt repo đã tồn tại"
fi
log "fullstack-mkt repo OK"

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
EOF
log "TOOLS.md OK"

# Create tokens.json
echo ""
warn "Tạo tokens.json..."
mkdir -p "$SKILLS_DIR/facebook-page-manager"
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

## ${BUSINESS_NAME}

## n8n Webhook
- URL: ${N8N_URL}/webhook/${N8N_WEBHOOK_ID}

## Facebook
- Page ID: ${FB_PAGE_ID}

## Skills (OpenClaw)

| Skill | Role |
|-------|------|
| content-writer | SA3: Viết content Facebook |
| marketing-planner | SA2: Lên kế hoạch content |
| facebook-page-manager | SA4: Đăng bài Facebook |
| baserow-integration | Kết nối Baserow |
| image-designer | SA1: Design ảnh |
| social-media-manager | Quản lý đa kênh |
| n8n-workflow-engineering | n8n workflows |

## MKT Knowledge (bonus)
- fullstack-mkt/ - 16 MKT knowledge files

## Baserow Tables (CREATED MANUALLY)
### Content Calendar
- Ngày đăng, Kênh đăng, Tiêu đề ngắn, Content bài đăng, Link ảnh đã thiết kế, Trạng thái, Ghi chú

### Product Database
- Tên thiết bị, Link ảnh, Link sản phẩm

## Workflow
1. Content (SA3) → Import Baserow
2. Design (n8n) → Webhook → Update Baserow
3. Post (SA4) → Facebook Schedule
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

# Summary
echo ""
echo "============================================"
echo "OPENCLAW SKILLS ĐÃ COPY:"
for skill in $SKILLS_TO_COPY; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        echo "  ✅ $skill"
    else
        echo "  ❌ $skill"
    fi
done

echo ""
echo "MKT KNOWLEDGE:"
if [ -d "$SKILLS_DIR/fullstack-mkt" ]; then
    echo "  ✅ fullstack-mkt/"
else
    echo "  ❌ fullstack-mkt"
fi

echo "
╔═══════════════════════════════════════════════════════════════╗
║                 ✅ SETUP HOÀN THÀNH                          ║
╠═══════════════════════════════════════════════════════════════╣
║  FILES:                                                     ║
║    - ~/.openclaw/workspace/TOOLS.md                         ║
║    - ~/.openclaw/workspace/PLAYBOOK.md                      ║
║    - ~/.openclaw/workspace/skills/                          ║
╠═══════════════════════════════════════════════════════════════╣
║  NEXT STEPS:                                                 ║
║    1. Create Baserow tables MANUALLY on Baserow UI         ║
║    2. Import n8n workflow (SA Designer Fixed)               ║
║    3. Test full workflow                                    ║
╚═══════════════════════════════════════════════════════════════╝
"
