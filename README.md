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

## Cấu trúc sau Setup

```
~/.openclaw/workspace/
├── setup-tool/                    # Tool này
├── skills/                        # OpenClaw Skills (từ repo)
│   ├── content-writer/             # ✅ SA3: Viết content Facebook
│   │   └── SKILL.md
│   ├── marketing-planner/          # ✅ SA2: Lên kế hoạch content
│   │   └── SKILL.md
│   ├── facebook-page-manager/      # ✅ SA4: Đăng bài Facebook
│   │   └── SKILL.md
│   ├── baserow-integration/       # ✅ Kết nối Baserow
│   │   └── SKILL.md
│   ├── image-designer/             # ✅ SA1: Design ảnh
│   │   └── SKILL.md
│   ├── social-media-manager/       # ✅ Quản lý đa kênh
│   │   └── SKILL.md
│   └── n8n-workflow-engineering/   # ✅ n8n workflows
│       └── SKILL.md
├── fullstack-mkt/                # 📚 MKT Knowledge (bonus)
│   ├── 00-ke-hoach-mkt.md
│   ├── 01-lich-noi-dung.md
│   └── ...
├── memory/                        # Ghi chú hàng ngày
├── TOOLS.md                       # Credentials
└── PLAYBOOK.md                   # System documentation
```

---

## OpenClaw Skills (từ repo - ✅ DÙNG ĐƯỢC)

| Skill | Role | File |
|-------|------|------|
| content-writer | SA3: Viết content Facebook | `SKILL.md` |
| marketing-planner | SA2: Lên kế hoạch content | `SKILL.md` |
| facebook-page-manager | SA4: Đăng bài Facebook | `SKILL.md` |
| baserow-integration | Kết nối Baserow CRUD | `SKILL.md` |
| image-designer | SA1: Design ảnh | `SKILL.md` |
| social-media-manager | Quản lý đa kênh | `SKILL.md` |
| n8n-workflow-engineering | n8n workflows | `SKILL.md` |

---

## MKT Knowledge (bonus - 📖 Tham khảo)

| File | Mô tả |
|------|-------|
| 00-ke-hoach-mkt.md | Kế hoạch marketing |
| 01-lich-noi-dung.md | Lịch nội dung |
| 02-brief-chien-dich.md | Brief chiến dịch |
| 03-danh-gia-hieu-suat.md | Đánh giá hiệu suất |
| ... | ... |

---

## ⚠️ Baserow Tables - TẠO TAY

Baserow **KHÔNG cho phép tạo table qua API**.

### Content Calendar Table
| Field | Type |
|-------|------|
| Ngày đăng | date |
| Kênh đăng | single_select |
| Tiêu đề ngắn | text |
| Content bài đăng | long_text |
| Link ảnh đã thiết kế | text |
| Trạng thái | single_select |
| Ghi chú | text |

### Product Database Table
| Field | Type |
|-------|------|
| Tên thiết bị | text |
| Link ảnh | url |
| Link sản phẩm | url |

---

## Workflow hàng ngày

```
1. Spawn SA3 (content-writer)
   → Viết N bài content
   → Import vào Baserow

2. Gọi n8n webhook (SA Designer)
   → Design ảnh
   → Update "Link ảnh đã thiết kế" vào Baserow

3. Spawn SA4 (facebook-page-manager)
   → Schedule post (09:00 VN)
   → Update "Trạng thái" = Done
```

---

## Setup cho khách mới

```bash
# 1. Clone repo
git clone https://github.com/minhnv0807/hq-design-mkt-tool.git ~/.openclaw/workspace/setup-tool

# 2. Chạy setup
bash ~/.openclaw/workspace/setup-tool/setup.sh

# 3. Tạo Baserow tables TAY

# 4. Xong!
```

---

**Version:** 2026-04-24
