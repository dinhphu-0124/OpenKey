# DinhPhuu_KEY — Bộ gõ Tiếng Việt cho macOS (v1.0.0)

Bản OpenKey đã được DinhPhu tùy chỉnh, sửa lỗi và đóng gói lại để chạy ổn định trên các phiên bản macOS mới.

Dựa trên [OpenKey](https://github.com/tuyenvm/OpenKey) — phần mềm gõ tiếng Việt mã nguồn mở, giấy phép **GPLv3**, tác giả gốc **Tuyền Mai** và cộng đồng OpenKey.

---

## 1. Nội dung thư mục

```
DinhPhuu_KEY/
├── README.md              <- File này
├── App/
│   └── OpenKey.app         <- Bản đã build sẵn, ký chữ ký thật, chạy được ngay
└── Source/
    ├── LICENSE                     <- Giấy phép GPLv3 (giữ nguyên từ bản gốc)
    ├── CHANGELOG.md                <- Lịch sử thay đổi của bản này
    ├── version.json
    └── Sources/OpenKey/
        ├── engine/          <- Engine gõ tiếng Việt (C++)
        └── macOS/           <- Project Xcode cho macOS (đã tùy chỉnh)
            ├── OpenKey.xcodeproj
            ├── ModernKey/           <- App chính (OpenKey.app)
            └── OpenKeyHelper/       <- Helper chạy nền (khởi động cùng máy)
```

Dự án này chỉ còn tối ưu cho **macOS**. Phần mã nguồn Windows/Linux của bản OpenKey gốc đã được gỡ bỏ khỏi bản này.

## 2. Những gì bản này khác với OpenKey gốc

**Tính năng mới:**
- Tự động viết hoa chữ cái đầu tiên ngay khi bắt đầu gõ vào một ô nhập liệu mới (bấm chuột vào ô mới), không chỉ sau dấu chấm câu như bản gốc.
- Nhập nhanh dữ liệu gõ tắt từ **Text Replacement** của macOS (mục Gõ tắt) — lấy luôn các từ viết tắt đã đồng bộ qua iCloud từ iPhone.

**Đã sửa lỗi (so với bản tải từ GitHub gốc):**
- Sửa lỗi không build được trên Xcode/macOS mới (API `AXAPIEnabled()` đã bị Apple gỡ; thiếu resource của module `OpenKeyUpdate`).
- Sửa lỗi treo cứng toàn bộ ứng dụng ngay khi khởi động (vòng lặp chặn sai trong bộ bắt phím).
- Sửa lỗi tiến trình nền `OpenKeyHelper` bị macOS chặn, không tự khởi động cùng máy được (chữ ký chứa cờ debug bị macOS mới coi là không hợp lệ).
- Sửa lỗi gõ sai dấu trong một số trường hợp, ảnh hưởng đến mọi bảng mã (do lỗi duyệt sai kiểu dữ liệu bảng nội bộ trong engine).
- Sửa hàng loạt nút/công tắc trong Cài đặt bị kết nối sai tên hàm nên bấm không có phản hồi (phím chuyển chế độ, khôi phục mặc định, mở bảng gõ tắt, đổi kiểu gõ/bảng mã, chế độ gõ Việt/Anh...).

**Đã bỏ bớt (không cần thiết):**
- Các tính năng tự động ghi nhớ/tạm tắt theo từng ứng dụng (chế độ gõ, bảng mã, tạm tắt OpenKey) — gây khó kiểm soát, người dùng tự chuyển khi cần thay vì để app tự động đổi ngầm.
- Tính năng sửa lỗi gợi ý trên trình duyệt Chromium/Excel, tính năng gửi từng phím.
- `OpenKeyUpdate` (tự kiểm tra bản cập nhật) không được build cùng do thiếu resource gốc — không ảnh hưởng đến việc gõ tiếng Việt.
- Toàn bộ mã nguồn Windows (`win32/`) và Linux (`linux/`) của bản gốc — dự án này chỉ tối ưu và duy trì cho macOS.

**Đánh đổi cần biết:** vì OpenKey không đọc nội dung ô văn bản để biết ô đó có đang trống hay không, tính năng tự viết hoa dùng "click chuột" làm tín hiệu bắt đầu phiên gõ mới. Hệ quả: nếu bạn click vào **giữa** một đoạn văn bản có sẵn để sửa (không phải ô trống), ký tự gõ tiếp theo cũng sẽ bị viết hoa nhầm.

## 3. Cách build lại từ source

Cần máy Mac có cài **Xcode đầy đủ** (không phải chỉ Command Line Tools).

```bash
cd Source/Sources/OpenKey/macOS
xcodebuild -project OpenKey.xcodeproj -scheme OpenKey -configuration Release \
  MACOSX_DEPLOYMENT_TARGET=10.15 \
  -derivedDataPath /tmp/openkey_build build
```

App build xong nằm ở: `/tmp/openkey_build/Build/Products/Release/OpenKey.app`

### Về việc ký code (quan trọng)

- Bản `App/OpenKey.app` đi kèm đã được ký bằng chứng chỉ **Apple Development** cá nhân (miễn phí, gắn với Apple ID). Nếu build lại **trên đúng máy này**, Xcode sẽ tự dùng lại chứng chỉ đó, quyền Accessibility đã cấp sẽ **không bị mất**.
- Nếu **người khác build lại trên máy của họ**: Xcode sẽ tự tạo chứng chỉ Development mới gắn với Apple ID của họ. Lần đầu chạy app, macOS sẽ hỏi cấp quyền Accessibility — cứ cấp bình thường (System Settings > Privacy & Security > Accessibility). Từ lần build thứ 2 trở đi trên máy đó, quyền sẽ giữ ổn định vì Team ID không đổi.
- **Không nên** build bằng chữ ký ad-hoc (`CODE_SIGN_IDENTITY="-"`) để dùng lâu dài — mỗi lần build lại, quyền Accessibility đã cấp sẽ bị macOS coi là không hợp lệ và phải cấp lại.

## 4. Cách cài đặt / dùng ngay (không cần build)

1. Copy `App/OpenKey.app` vào thư mục `Applications` của máy nhận.
2. Mở app (double-click). macOS sẽ hiện cảnh báo "không rõ nhà phát triển" vì app không được Apple công chứng (notarize) — chuột phải vào app > **Open** (chỉ cần làm 1 lần).
3. Hộp thoại "OpenKey cần bạn cấp quyền để có thể hoạt động!" hiện ra → bấm **Cấp quyền**.
4. Vào System Settings > Privacy & Security > Accessibility → bật công tắc **OpenKey**.
5. Mở lại `OpenKey.app` lần nữa.
6. Nếu tiến trình nền `OpenKeyHelper` chưa tự chạy: vào OpenKey, tắt rồi bật lại tùy chọn "Khởi động cùng macOS" trong mục Hệ thống để kích hoạt.

## 5. Giấy phép — GPLv3

OpenKey phát hành theo giấy phép **GPLv3** (xem `Source/LICENSE`). Vì bản này là phần mềm phái sinh (derivative work) từ OpenKey, theo đúng điều khoản của GPLv3, bản chỉnh sửa này **bắt buộc giữ nguyên giấy phép GPLv3** — không được đổi sang giấy phép khác.

- Dựa trên: <https://github.com/tuyenvm/OpenKey> — tác giả gốc: Tuyền Mai và cộng đồng OpenKey (GPLv3).
- Bản chỉnh sửa bởi: **DinhPhu** © 2026 — liên hệ: dinhphuhcmus15@gmail.com

Khi chia sẻ bản đã sửa này cho người khác, bạn **bắt buộc**:

- Kèm theo mã nguồn (thư mục `Source/` này) — đã có sẵn trong gói.
- Ghi rõ đây là bản chỉnh sửa dựa trên OpenKey gốc: <https://github.com/tuyenvm/OpenKey>.
- Giữ nguyên giấy phép GPLv3 cho bản phân phối lại.

Gói `DinhPhuu_KEY` này đã tuân thủ đủ các điều trên.
