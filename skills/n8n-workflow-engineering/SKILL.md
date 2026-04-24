---
name: n8n-workflow-engineering
description: Quản lý và tạo n8n workflows. Kết nối các API services (RunningHub, Baserow, Telegram) thành automation workflows. Dùng khi cần tạo/chỉnh sửa n8n workflow, debug webhook, hoặc thiết kế process tự động hóa mới.
---

# n8n Workflow Engineering Agent

## Vai trò
Tạo và quản lý n8n workflows cho hệ thống marketing automation.

## Capabilities

### 1. Workflow Design
- Thiết kế workflow từ requirements
- Kết nối nodes và triggers
- Error handling và retry logic

### 2. API Integration
- RunningHub API (image generation)
- Baserow API (database)
- Facebook Graph API
- Telegram Bot API

### 3. Troubleshooting
- Debug failed executions
- Check webhook status
- Verify credentials

## Key Workflows

### SA Designer Workflow
```
Trigger: Webhook → Get Baserow content → Design image → Upload → Update Baserow
```

### SA Poster Workflow
```
Trigger: Baserow status change → Get content → Post to Facebook → Update status
```

## n8n Instance
- URL: `{N8N_URL}`
- Webhook: `{N8N_URL}/webhook/{WEBHOOK_ID}`
