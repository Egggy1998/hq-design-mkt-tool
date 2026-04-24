# 3D Vietnam Marketing System - Setup Tool

## Cách dùng

```bash
# Bash script (nhanh nhất)
bash ~/.openclaw/workspace/setup-tool/setup.sh

# Node.js
node ~/.openclaw/workspace/setup-tool/setup.js
```

---

## Input (5 fields)

| # | Field | Ví dụ |
|---|-------|-------|
| 1 | n8n Instance URL | `https://jqqpar.ezn8n.com` |
| 2 | n8n Webhook ID | `c662501d-1d03-48c3-9bc2-4ad0e8e2b2a2` |
| 3 | Facebook Page ID | `1016972191499562` |
| 4 | Facebook Page Token | `EAAL1qA4ZC...` |
| 5 | Tên Business | `3D Vietnam` |

---

## Cấu trúc đầy đủ sau Setup

```
~/.openclaw/workspace/
├── setup-tool/                    # Tool này
├── skills/                        # Skills có sẵn trong workspace
│   ├── content-writer/            # SA3: Viết content Facebook
│   ├── marketing-planner/          # SA2: Lên kế hoạch content
│   ├── facebook-page-manager/      # SA4: Đăng bài Facebook
│   ├── baserow-integration/       # Kết nối Baserow
│   ├── social-media-manager/      # Quản lý đa kênh
│   ├── image-designer/            # SA1: Design ảnh (backup)
│   ├── n8n-workflow-engineering/ # n8n workflows
│   └── fullstack-mkt/             # 16 MKT files (bonus)
│       ├── 00-ke-hoach-mkt.md
│       ├── 01-lich-noi-dung.md
│       ├── ...
│       ├── 15-social-listening.md
│       ├── agents/
│       ├── references/
│       └── workflows/
├── memory/                        # Ghi chú hàng ngày
├── TOOLS.md                       # Credentials
├── PLAYBOOK.md                   # System documentation
└── ORCHESTRATION.md              # Agent orchestration
```

---

## Skills có sẵn

### 1. content-writer (SA3)
- **Mục đích:** Viết content Facebook 500-800 từ
- **Skill file:** `skills/content-writer/SKILL.md`
- **Input:** Brief sản phẩm
- **Output:** Content file + import vào Baserow

### 2. marketing-planner (SA2)
- **Mục đích:** Lên lịch content hàng tuần
- **Skill file:** `skills/marketing-planner/SKILL.md`
- **Input:** Product DB (Baserow)
- **Output:** Brief cho từng bài

### 3. facebook-page-manager (SA4)
- **Mục đích:** Đăng bài + schedule lên Facebook
- **Skill file:** `skills/facebook-page-manager/SKILL.md`
- **Input:** Content + image URL
- **Output:** Post ID từ Facebook

### 4. baserow-integration
- **Mục đích:** CRUD operations trên Baserow
- **Skill file:** `skills/baserow-integration/SKILL.md`
- **Input:** Table ID + row data
- **Output:** Updated rows

### 5. image-designer (SA1 - backup)
- **Mục đích:** Design ảnh poster
- **Skill file:** `skills/image-designer/SKILL.md`
- **Input:** Product image + content
- **Output:** Designed image URL

---

## Bonus: fullstack-mkt (16 files)

```
skills/fullstack-mkt/
├── 00-ke-hoach-mkt.md      # Kế hoạch marketing
├── 01-lich-noi-dung.md    # Lịch nội dung
├── 02-brief-chien-dich.md # Brief chiến dịch
├── 03-danh-gia-hieu-suat.md
├── 04-script-video.md     # Script video
├── 05-copy-quang-cao.md   # Copy quảng cáo
├── 06-brief-ugc-egc.md
├── 07-bao-cao-marketing.md
├── 08-nghien-cuu-doi-thu.md
├── 09-insight-khach-hang.md
├── 10-tinh-kpi-nguoc.md
├── 11-thiet-lap-kenh.md
├── 12-brief-landing-page.md
├── 13-phan-tich-du-lieu.md
├── 14-email-marketing.md
├── 15-social-listening.md
└── agents/               # Sub-agents
    ├── mkt-strategist.md
    ├── performance-analyst.md
    ├── content-producer.md
    └── channel-operator.md
```

---

## ⚠️ Baserow Tables - TẠO TAY

Baserow **KHÔNG cho phép tạo table qua API**.

### Content Calendar Table (ID: {CONTENT_TABLE_ID})
| Field | Type |
|-------|------|
| Ngày đăng | date |
| Kênh đăng | single_select |
| Tiêu đề ngắn | text |
| Content bài đăng | long_text |
| Link ảnh đã thiết kế | text |
| Trạng thái | single_select |
| Ghi chú | text |

### Product Database Table (ID: {PRODUCT_TABLE_ID})
| Field | Type |
|-------|------|
| Tên thiết bị | text |
| Link ảnh | url |
| Link sản phẩm | url |

---

## Baserow API Endpoints

```
GET    https://api.baserow.io/api/database/rows/table/{table_id}/?user_field_names=true
POST   https://api.baserow.io/api/database/rows/table/{table_id}/
PATCH  https://api.baserow.io/api/database/rows/table/{table_id}/{row_id}/
DELETE https://api.baserow.io/api/database/rows/table/{table_id}/{row_id}/
```

---

## n8n Workflow

**Webhook URL:** `{N8N_URL}/webhook/{WEBHOOK_ID}`

**Payload format:**
```json
{
  "row_id": 297,
  "baserow_row_id": 297,
  "content": "Nội dung bài viết...",
  "product_image_url": "https://..."
}
```

---

## Workflow hàng ngày

```
1. Spawn SA3 (content-writer)
   → Viết N bài content
   → Import vào Baserow Table 916632

2. Gọi n8n webhook (SA Designer)
   → Design ảnh
   → Update "Link ảnh đã thiết kế" vào Baserow

3. Spawn SA4 (facebook-page-manager)
   → Lấy content + ảnh từ Baserow
   → Schedule post (09:00 VN)
   → Update "Trạng thái" = Done
```

---

## Setup cho khách mới

```bash
# 1. Chạy setup script
bash setup.sh

# 2. Skills được copy tự động vào ~/.openclaw/workspace/skills/

# 3. Hướng dẫn khách tạo Baserow tables TAY

# 4. Xong!
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| FB token expired | Get new from Graph API Explorer |
| Baserow 404 | Use api.baserow.io (no /v1/) |
| Skills not found | Check skills/ folder exists |
| n8n webhook timeout | Dùng production URL |

---

**Version:** 2026-04-24
