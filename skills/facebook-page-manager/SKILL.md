---
name: facebook-page
description: Manage Facebook Pages via Meta Graph API. Post content (text, photos, links), schedule posts, list posts, manage comments (list/reply/hide/delete). Use when user wants to publish to Facebook Page, schedule posts, check Page posts, or handle comments.
---

# Facebook Page

Skill để quản lý Facebook Page qua Meta Graph API.

## Chức năng
- List các Page mà user quản lý
- Đăng bài ngay (text, ảnh, link)
- **Schedule bài đăng theo ngày giờ cụ thể**
- List bài đăng của Page
- List/reply/hide/delete comment

---

## 📅 SCHEDULE POST ( Quan trọng! )

### Cách tính Timestamp

**Quy tắc:**
- Timestamp phải là UNIX timestamp (giây, không phải mili giây)
- Phải là THỜI GIAN TƯƠNG LAI (ít nhất 10 phút kể từ bây giờ)
- Múi giờ: **09:00 VN = 02:00 UTC**

### Công thức tính timestamp cho 09:00 VN

```bash
# Tính timestamp cho ngày cụ thể
date -d "YYYY-MM-DDT02:00:00Z" +%s

# Ví dụ: 25/04/2026 09:00 VN
date -d "2026-04-25T02:00:00Z" +%s
# Kết quả: 1777082400
```

### Danh sách Timestamp thường dùng (09:00 VN)

| Ngày | Timestamp |
|------|----------|
| 2026-04-25 | 1777082400 |
| 2026-04-26 | 1777168800 |
| 2026-04-27 | 1777255200 |
| 2026-04-28 | 1777341600 |
| 2026-04-29 | 1777428000 |
| 2026-04-30 | 1777514400 |

---

## 📤 Đăng bài SCHEDULED

### Format cơ bản

```bash
curl -X POST "https://graph.facebook.com/v19.0/{page_id}/feed" \
  -F "message={content}" \
  -F "link={image_url}" \
  -F "published=false" \
  -F "scheduled_publish_time={timestamp}" \
  -F "access_token={page_token}"
```

### Ví dụ thực tế

```bash
PAGE_ID="1016972191499562"
PAGE_TOKEN="EAAW...your_page_token"
TIMESTAMP="1777082400"  # 25/04/2026 09:00 VN

curl -X POST "https://graph.facebook.com/v19.0/${PAGE_ID}/feed" \
  -F "message=Chào mừng bạn đến với 3D Laser Beauty! ..." \
  -F "link=https://example.com/image.jpg" \
  -F "published=false" \
  -F "scheduled_publish_time=${TIMESTAMP}" \
  -F "access_token=${PAGE_TOKEN}"
```

### Response thành công

```json
{
  "id": "1016972191499562_122109040647023513",
  "success": true
}
```

### Response lỗi thường gặp

| Lỗi | Nguyên nhân | Giải pháp |
|------|-------------|-----------|
| `scheduled_publish_time is invalid` | Timestamp đã qua hoặc format sai | Dùng timestamp tương lai, tính lại bằng `date -d` |
| `Unpublished posts must be posted as the page` | Token không phải Page Token | Lấy Page Token từ `/me/accounts` |
| `(#200) does not have publish_actions` | Thiếu quyền | Kiểm tra token có `pages_manage_posts` |

---

## ⏰ Tính Timestamp cho bất kỳ ngày nào

```bash
# Công thức: date -d "YYYY-MM-DDT02:00:00Z" +%s

# Hôm nay + N ngày, 09:00 VN
TOMORROW=$(date -d "+1 day" +%Y-%m-%d)
date -d "${TOMORROW}T02:00:00Z" +%s

# Ngày cụ thể
date -d "2026-05-01T02:00:00Z" +%s
```

---

## 📋 Workflow cho Schedule Post

### Bước 1: Chuẩn bị data

```json
{
  "page_id": "1016972191499562",
  "page_token": "EAAW...token",
  "content": "Nội dung bài viết...",
  "image_url": "https://example.com/image.jpg",
  "scheduled_date": "2026-04-25",
  "scheduled_time": "09:00"
}
```

### Bước 2: Tính timestamp

```bash
TIMESTAMP=$(date -d "2026-04-25T02:00:00Z" +%s)
echo "Timestamp: $TIMESTAMP"
# Output: 1777082400
```

### Bước 3: Gọi API

```bash
curl -X POST "https://graph.facebook.com/v19.0/${PAGE_ID}/feed" \
  -F "message=${content}" \
  -F "link=${image_url}" \
  -F "published=false" \
  -F "scheduled_publish_time=${TIMESTAMP}" \
  -F "access_token=${PAGE_TOKEN}"
```

### Bước 4: Kiểm tra response

```json
// Thành công
{"id": "1016972191499562_122109040647023513"}

// Lỗi
{"error": {"message": "...", "code": 100}}
```

---

## Setup (một lần)

### 1. Tạo Meta App
1. Vào https://developers.facebook.com/apps/ → Create App
2. Chọn **"Other"** → **"Business"**
3. Lấy **App ID** và **App Secret**

### 2. Cấu hình .env
```bash
cp .env.example .env
# Edit .env với App ID và Secret
```

### 3. Lấy Token
```bash
cd scripts
npm install
node auth.js login
```

## Commands

### List pages
```bash
node cli.js pages
```

### Đăng bài ngay
```bash
node cli.js post create --page PAGE_ID --message "Hello"
```

### Schedule bài đăng
```bash
node cli.js post schedule \
  --page PAGE_ID \
  --message "Nội dung bài viết" \
  --link "https://image.jpg" \
  --date "2026-04-25" \
  --time "09:00"
```

### List posts
```bash
node cli.js post list --page PAGE_ID --limit 10
```

### Comments
```bash
node cli.js comments list --post POST_ID
node cli.js comments reply --comment COMMENT_ID --message "Thanks!"
node cli.js comments hide --comment COMMENT_ID
```

## Permissions cần thiết
- `pages_show_list`
- `pages_read_engagement`
- `pages_manage_posts`
- `pages_manage_engagement`

## Lưu ý
- Page Token cần có quyền `pages_manage_posts`
- Timestamp phải là tương lai (ít nhất 10 phút)
- 09:00 VN = 02:00 UTC
