# HQ Design Marketing System - Setup Tool

## Cách dùng

```bash
# Bash script
bash setup.sh

# Node.js
node setup.js
```

---

## Input (5 fields)

| # | Field | Ví dụ |
|---|-------|-------|
| 1 | n8n Instance URL | `https://your-n8n.workers.dev` |
| 2 | n8n Webhook ID | `your-webhook-id` |
| 3 | Facebook Page ID | `your-page-id` |
| 4 | Facebook Page Token | `your-fb-token` |
| 5 | Tên Business | `Your Business Name` |

---

## Cấu trúc sau Setup

```
~/.openclaw/workspace/
├── setup-tool/                    # Tool này
├── skills/                        # OpenClaw Skills (từ repo)
│   ├── content-writer/             # ✅ SA3: Viết content
│   ├── marketing-planner/          # ✅ SA2: Lên kế hoạch
│   ├── facebook-page-manager/      # ✅ SA4: Đăng bài Facebook
│   ├── baserow-integration/       # ✅ Kết nối Baserow
│   ├── image-designer/             # ✅ SA1: Design ảnh
│   ├── social-media-manager/       # ✅ Quản lý đa kênh
│   └── n8n-workflow-engineering/   # ✅ n8n workflows
└── ...
```

---

## Skills

| Skill | Role |
|-------|------|
| content-writer | SA3: Viết content Facebook |
| marketing-planner | SA2: Lên kế hoạch content |
| facebook-page-manager | SA4: Đăng bài Facebook |
| baserow-integration | Kết nối Baserow CRUD |
| image-designer | SA1: Design ảnh |
| social-media-manager | Quản lý đa kênh |
| n8n-workflow-engineering | n8n workflows |

---

## Lưu ý bảo mật

- Token Facebook Page **KHÔNG** lưu vào GitHub
- Token được tạo local trong `tokens.json` (gitignore)
- Baserow token được nhập khi setup

---

## Repo chính

```
https://github.com/Egggy1998/hq-design-mkt-tool
```
