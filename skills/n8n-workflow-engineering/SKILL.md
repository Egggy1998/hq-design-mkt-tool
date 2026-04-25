---
name: n8n-workflow-engineering
description: Kết nối và điều phối n8n workflows cho hệ thống marketing automation. Dùng khi cần trigger design images, kiểm tra workflow status, hoặc debug n8n.
---

# n8n Workflow Engineering Agent

## Vai trò trong hệ thống

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION FLOW                            │
│                                                                 │
│  SA2 Marketing Planner → Baserow (brief)                        │
│       ↓                                                          │
│  SA3 Content Writer → Tạo content hoàn chỉnh                    │
│       ↓                                                          │
│  Gọi n8n webhook → Design ảnh sản phẩm                          │
│       ↓                                                          │
│  SA4 Facebook Poster → Schedule posts                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔗 n8n Webhook

### Webhook URL Format

```
POST https://YOUR_N8N_INSTANCE/webhook/YOUR_WEBHOOK_ID
Content-Type: application/json
```

### Request Body

```json
{
  "row_id": 297,
  "baserow_row_id": 297,
  "content": "Nội dung bài viết...",
  "product_image_url": "https://baserow.example.com/image.jpg",
  "product_name": "Tên sản phẩm",
  "scheduled_date": "2026-04-25"
}
```

### Response

```json
{
  "success": true,
  "message": "Workflow triggered"
}
```

---

## 📋 Pipeline SA3 → n8n

### Bước 1: Chuẩn bị payload

```javascript
const payload = {
  row_id: baserow_row_id,
  baserow_row_id: baserow_row_id,
  content: content_text,
  product_image_url: product_image,
  product_name: product_name,
  scheduled_date: scheduled_date
};
```

### Bước 2: Gọi webhook

```bash
curl -X POST "https://YOUR_N8N_INSTANCE/webhook/YOUR_WEBHOOK_ID" \
  -H "Content-Type: application/json" \
  -d "$(echo $payload | jq -c .)"
```

### Bước 3: Monitor status

Kiểm tra Baserow field "Trạng thái":
- `Designing` → đang xử lý
- `Designed` → xong
- `Scheduled` → đã lên lịch

---

## 🛠️ Debug n8n Workflows

### Check workflow runs

1. Login n8n dashboard
2. Workflow → Executions
3. Tìm execution gần nhất

### Common issues

| Issue | Solution |
|-------|----------|
| Webhook not triggered | Kiểm tra webhook URL, credentials |
| Image not generated | Check RunningHub API status |
| Baserow update failed | Verify token + table ID |

---

## 📚 Tham Khảo

- n8n Docs: https://docs.n8n.io/
- Webhook nodes: https://docs.n8n.io/nodes/n8n-nodes-base.webhook/
