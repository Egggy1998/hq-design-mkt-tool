---
name: n8n-workflow-engineering
description: Kết nối và điều phối n8n workflows qua Cloudflare Worker webhook cho hệ thống marketing. Worker đảm bảo 100% uptime. Dùng khi cần trigger design, kiểm tra status, hoặc debug workflow.
---

# n8n Workflow Engineering Agent

## Vai trò trong hệ thống

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION FLOW                            │
│                                                                 │
│  SA2 Marketing Planner                                          │
│       ↓ Brief                                                   │
│  SA3 Content Writer                                             │
│       ↓ Content hoàn chỉnh                                      │
│       ↓ Gọi Cloudflare Worker ─────────────────────────┐       │
│       ↓ (100% uptime)                                  ↓       │
│  Cloudflare Worker                                         │
│       ↓ Forwards to n8n                                   │
│  n8n SA Designer ────────────────────────────────────┘       │
│       ↓ Design xong                                         │
│       ↓ Update Baserow                                       │
│  SA4 Facebook Poster                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌐 Cloudflare Worker Webhook

### Endpoint

```
POST https://YOUR_SUBDOMAIN.workers.dev
Content-Type: application/json
```

### Request Body Format

```json
{
  "row_id": 297,
  "baserow_row_id": 297,
  "content": "Nội dung bài viết đầy đủ...",
  "product_image_url": "https://example.com/image.jpg",
  "product_name": "Diode Laser 808nm",
  "scheduled_date": "2026-04-25"
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `row_id` | number | ✅ | Row ID trên Baserow |
| `baserow_row_id` | number | ✅ | Baserow row ID |
| `content` | string | ✅ | Nội dung bài viết |
| `product_image_url` | string | ✅ | URL ảnh sản phẩm |
| `product_name` | string | ❌ | Tên sản phẩm |
| `scheduled_date` | string | ❌ | Ngày đăng (YYYY-MM-DD) |

### Response Format

```json
{
  "success": true,
  "message": "Webhook received and forwarded",
  "row_id": 297,
  "n8n_status": "sent"
}
```

---

## 🚀 Cách Tự Set Up Cloudflare Worker

### Bước 1: Chuẩn bị

```bash
# Cài Wrangler CLI
npm install -g wrangler

# Login Cloudflare
wrangler login
```

### Bước 2: Clone Worker Repo

```bash
# Clone repo
git clone https://github.com/Egggy1998/3d-vietnam-worker.git
cd 3d-vietnam-worker
```

### Bước 3: Deploy

```bash
# Deploy lên Cloudflare
wrangler deploy
```

### Bước 4: Set Environment Variables

Trên Cloudflare Dashboard:
1. Workers & Pages → Chọn `3d-vietnam-worker`
2. Settings → Variables
3. Add variables:

| Variable | Value |
|----------|-------|
| `N8N_WEBHOOK_URL` | `https://jqqpar.ezn8n.com` |
| `N8N_WEBHOOK_ID` | `c662501d-1d03-48c3-9bc2-4ad0e8e2b2a2` |
| `BASEROW_TABLE_ID` | `916632` |

### Bước 5: Set Secret

```bash
# Set Baserow token (sẽ được bảo mật)
wrangler secret put BASEROW_TOKEN
# Nhập: k3h0ecJo2awlsDTc2cctP1H5EhNMs4yo
```

### Bước 6: Lấy Worker URL

```bash
# Xem Worker URL
wrangler subdomain
# Kết quả: https://3d-vietnam-worker.YOUR_SUBDOMAIN.workers.dev
```

---

## Pipeline gọi Cloudflare Worker (SA3)

### Bước 1 — Chuẩn bị payload

```javascript
const payload = {
  "row_id": baserow_row_id,
  "baserow_row_id": baserow_row_id,
  "content": content_text,
  "product_image_url": product_image_from_baserow,
  "product_name": product_name,
  "scheduled_date": scheduled_date
};
```

### Bước 2 — Gọi Cloudflare Worker

```bash
curl -X POST "https://YOUR_SUBDOMAIN.workers.dev" \
  -H "Content-Type: application/json" \
  -d '{
    "row_id": 297,
    "baserow_row_id": 297,
    "content": "Bài viết content...",
    "product_image_url": "https://baserow.example.com/files/image.jpg",
    "product_name": "Diode Laser 808nm",
    "scheduled_date": "2026-04-25"
  }'
```

### Bước 3 — Xử lý response

```javascript
// Response thành công
if (response.success) {
  // Cloudflare Worker đã forward đến n8n
  console.log("Design triggered:", response.n8n_status);
  // → Chuyển sang theo dõi Baserow
} else {
  // Xử lý lỗi
  console.error("Failed:", response.error);
}
```

---

## 🔄 Cloudflare Worker Flow

```
Cloudflare Worker
    ↓ Validate request
    ↓ Forward to n8n webhook
    ↓ Update Baserow status = "Designing"
    ↓ Return success response
```

### Worker Features
- ✅ 100% uptime (edge network)
- ✅ Auto-retry on n8n failure
- ✅ CORS enabled
- ✅ Request validation

---

## n8n Workflow (SA Designer)

### Trigger: n8n Webhook
```
n8n receives forwarded request
    ↓
Get Baserow row data
    ↓
RunningHub API → Image generation
    ↓
Upload → Get public URL
    ↓
Update Baserow field "Link ảnh đã thiết kế"
    ↓
Done!
```

---

## Error Handling

### Worker Errors

| Error | Xử lý |
|-------|--------|
| Invalid JSON | Log payload, return 400 |
| Missing fields | Return 400 with field names |
| n8n timeout | Worker auto-retry |
| n8n not responding | Log and continue |

### Retry Logic

Worker sẽ retry n8n request tối đa 3 lần nếu fail.

---

## Test Webhook

```bash
# Test với sample data
curl -X POST "https://YOUR_SUBDOMAIN.workers.dev" \
  -H "Content-Type: application/json" \
  -d '{
    "row_id": 999,
    "baserow_row_id": 999,
    "content": "Test content",
    "product_image_url": "https://example.com/test.jpg"
  }'
```

---

## Environment Variables (Cloudflare)

Được config trên Cloudflare Dashboard:

| Variable | Value |
|----------|-------|
| `N8N_WEBHOOK_URL` | `https://jqqpar.ezn8n.com` |
| `N8N_WEBHOOK_ID` | `c662501d-1d03-48c3-9bc2-4ad0e8e2b2a2` |
| `BASEROW_TABLE_ID` | `916632` |

**Secret (cần set riêng):**
- `BASEROW_TOKEN` | `k3h0ecJo2awlsDTc2cctP1H5EhNMs4yo` (set qua `wrangler secret put`)

---

## Dependencies

- `content-writer/SKILL.md` — SA3 gọi Cloudflare Worker
- `baserow-integration/SKILL.md` — Update Baserow fields

---

## 📚 Tham Khảo

- Cloudflare Workers Docs: https://developers.cloudflare.com/workers/
- Wrangler CLI: https://developers.cloudflare.com/workers/wrangler/
- Worker Repo: https://github.com/Egggy1998/3d-vietnam-worker
