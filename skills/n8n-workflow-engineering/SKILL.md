---
name: n8n-workflow-engineering
description: Kết nối và điều phối n8n workflows cho hệ thống marketing. Gọi webhook để kích hoạt SA Designer design ảnh. Dùng khi cần trigger design, kiểm tra n8n status, hoặc debug workflow.
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
│       ↓ Content hoàn chỉnh                                       │
│       ↓ Gọi n8n webhook ──────────────────────────────────┐   │
│       ↓                                                ↓       │
│  SA Designer (n8n)                            SA4 Facebook   │
│       ↓ Design xong                          ←───────────────┘   │
│       ↓ Update Baserow                                        │
│  Done!                                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Webhook Format (SA Designer)

### Trigger Endpoint

```
POST {N8N_URL}/webhook/{WEBHOOK_ID}
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
| `baserow_row_id` | number | ✅ | Baserow row ID (trùng row_id) |
| `content` | string | ✅ | Nội dung bài viết đầy đủ |
| `product_image_url` | string | ✅ | URL ảnh sản phẩm thật từ Baserow |
| `product_name` | string | ❌ | Tên sản phẩm (để generate prompt) |
| `scheduled_date` | string | ❌ | Ngày đăng (YYYY-MM-DD) |

### Response Format (từ n8n)

```json
{
  "success": true,
  "image_url": "https://uploaded-image-url.jpg",
  "baserow_row_id": 297,
  "message": "Design completed and uploaded to Baserow"
}
```

---

## Pipeline gọi n8n Webhook (SA3)

### Bước 1 — Chuẩn bị payload

```javascript
// Payload chuẩn để gửi webhook
const payload = {
  "row_id": baserow_row_id,
  "baserow_row_id": baserow_row_id,
  "content": content_text,
  "product_image_url": product_image_from_baserow,
  "product_name": product_name,
  "scheduled_date": scheduled_date
};
```

### Bước 2 — Gọi webhook

```bash
curl -X POST "https://{N8N_URL}/webhook/{WEBHOOK_ID}" \
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
  // n8n đã update Baserow field "Link ảnh đã thiết kế"
  console.log("Design completed:", response.image_url);
  // → Chuyển sang SA4 đăng bài
} else {
  // Xử lý lỗi
  console.error("Design failed:", response.message);
  // → Retry hoặc manual design
}
```

### Bước 4 — Kiểm tra Baserow

Sau khi n8n webhook return success, kiểm tra Baserow:

```bash
curl -s "https://api.baserow.io/api/database/rows/table/{TABLE_ID}/{row_id}/?user_field_names=true" \
  -H "Authorization: Token {BASEROW_TOKEN}" | jq '.["Link ảnh đã thiết kế"]'
```

---

## n8n Workflow (SA Designer)

### Trigger: Webhook

```
Webhook Node
    ↓
HTTP Request → Parse JSON body
    ↓
Baserow Node → Get full row data
    ↓
RunningHub API → Image generation (image-to-image)
    ↓
Upload → Get public URL
    ↓
Baserow Node → Update field "Link ảnh đã thiết kế"
    ↓
Response → {"success": true, "image_url": "..."}
```

### RunningHub Image Gen Payload

```json
{
  "prompt": "Professional spa equipment poster, [content extracted headline], modern clean design, Vietnamese text overlay",
  "imageUrls": ["{product_image_url}"],
  "aspectRatio": "3:2"
}
```

---

## Error Handling

### Webhook Errors

| Error | Xử lý |
|-------|--------|
| Connection timeout | Retry 1 lần, sau 5s |
| Invalid JSON | Log payload, check format |
| n8n not responding | Check n8n instance status |

### Image Generation Errors

| Error | Xử lý |
|-------|--------|
| RunningHub API error | Retry với prompt đơn giản hơn |
| Image upload failed | Retry upload hoặc manual |
| Prompt too long | Truncate content, keep headline |

---

## Test Webhook

```bash
# Test với sample data
curl -X POST "https://{N8N_URL}/webhook/{WEBHOOK_ID}" \
  -H "Content-Type: application/json" \
  -d '{
    "row_id": 999,
    "baserow_row_id": 999,
    "content": "Test content for webhook",
    "product_image_url": "https://example.com/test.jpg",
    "product_name": "Test Product"
  }'
```

---

## Configuration

| Variable | Source | Description |
|---------|--------|-------------|
| `N8N_URL` | TOOLS.md | n8n instance URL |
| `N8N_WEBHOOK_ID` | TOOLS.md | Webhook ID |
| `BASEROW_TOKEN` | TOOLS.md | Baserow API token |
| `BASEROW_TABLE_ID` | TOOLS.md | Content calendar table ID |

---

## Dependencies

- `content-writer/SKILL.md` — SA3 gọi webhook này
- `baserow-integration/SKILL.md` — Update Baserow fields
