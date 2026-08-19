------
# DinhPhuu_KEY - Bộ gõ Tiếng Việt cho macOS (v1.0.0)

Bản OpenKey đã được DinhPhuu tùy chỉnh, sửa lỗi và đóng gói lại để chạy ổn định trên các phiên bản macOS mới.

Dựa trên [OpenKey](https://github.com/tuyenvm/OpenKey) — phần mềm gõ tiếng Việt mã nguồn mở, giấy phép **GPLv3**, tác giả gốc **Tuyền Mai** và cộng đồng OpenKey.

------
## 1. Cách cài đặt / dùng ngay (không cần build)

1. Tải file `OpenKey.dmg` ở mục [Releases](https://github.com/dinhphu-0124/OpenKey/releases) về máy.
2. Mở file `OpenKey.dmg`.
3. Trong cửa sổ hiện ra, kéo biểu tượng `OpenKey` vào thư mục `Applications`.
4. Mở thư mục `Applications` và double-click `OpenKey`.
5. Nếu macOS hiện cảnh báo "OpenKey không thể mở vì nhà phát triển không thể được xác minh" (vì app không được Apple công chứng/notarize) → chuột phải vào `OpenKey` → chọn **Open** → chọn **Open** một lần nữa. Chỉ cần làm bước này lần đầu.
6. Hộp thoại "OpenKey cần bạn cấp quyền để có thể hoạt động!" hiện ra → bấm **Cấp quyền**.
7. Vào System Settings → Privacy & Security → Accessibility → tìm **OpenKey** → bật công tắc.
8. Mở lại `OpenKey`.
9. Nếu tiến trình nền `OpenKeyHelper` chưa tự chạy: mở **OpenKey** → vào mục **Hệ thống** → tắt rồi bật lại tùy chọn **Khởi động cùng macOS**.

Sau khi hoàn tất, OpenKey có thể được sử dụng bình thường.

> `App/OpenKey.app` trong repo vẫn được giữ nguyên cho ai muốn build hoặc kiểm tra thủ công; file `.dmg` trên trang Releases được đóng gói tự động từ đúng file này mỗi khi có bản phát hành mới (xem `.github/workflows/release.yml`).


## 2. Cách build lại từ source

Cần máy Mac có cài **Xcode đầy đủ** (không phải chỉ Command Line Tools).

```bash
cd Source/Sources/OpenKey/macOS
xcodebuild -project OpenKey.xcodeproj -scheme OpenKey -configuration Release \
  MACOSX_DEPLOYMENT_TARGET=10.15 \
  -derivedDataPath /tmp/openkey_build build
```

App build xong nằm ở: `/tmp/openkey_build/Build/Products/Release/OpenKey.app`


## 3. Giấy phép — GPLv3

OpenKey phát hành theo giấy phép **GPLv3** (xem `Source/LICENSE`). Vì bản này là phần mềm phái sinh (derivative work) từ OpenKey, theo đúng điều khoản của GPLv3, bản chỉnh sửa này **bắt buộc giữ nguyên giấy phép GPLv3** — không được đổi sang giấy phép khác.

- Dựa trên: <https://github.com/tuyenvm/OpenKey> - tác giả gốc: Tuyền Mai và cộng đồng OpenKey (GPLv3).
- Bản chỉnh sửa bởi: **DinhPhu** © 2026 - liên hệ: dinhphuhcmus15@gmail.com
