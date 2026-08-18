# DinhPhuu_KEY

Bản OpenKey đã được vá (patch) để **tự viết hoa chữ cái đầu tiên ngay khi bắt đầu gõ vào một ô nhập liệu mới** — không chỉ sau dấu `.` như bản gốc.

Dựa trên [OpenKey](https://github.com/tuyenvm/OpenKey) phiên bản 2.0.5 (mã nguồn mở, giấy phép GPLv3).
Repository: <https://github.com/dinhphu-0124/OpenKey>

---

## 1. Nội dung thư mục

```
DinhPhuu_KEY/
├── README.md              <- File này
├── App/
│   └── OpenKey.app         <- Bản đã build sẵn, ký chữ ký thật, chạy được ngay
└── Source/
    ├── LICENSE                     <- Giấy phép GPLv3 (giữ nguyên từ bản gốc)
    ├── CHANGELOG_OpenKey_goc.md    <- Changelog gốc của OpenKey
    ├── version.json
    └── Sources/OpenKey/
        ├── engine/          <- Engine gõ tiếng Việt (C++, dùng chung mọi nền tảng)
        ├── macOS/           <- Project Xcode cho macOS (đã patch)
        │   ├── OpenKey.xcodeproj
        │   ├── ModernKey/           <- App chính (OpenKey.app)
        │   ├── OpenKeyHelper/       <- Helper chạy nền (xử lý gõ phím thật)
        │   └── OpenKeyUpdate/       <- (thiếu resource gốc, xem mục 4)
        ├── win32/           <- Bản Windows (không dùng ở đây)
        └── linux/
```

## 2. Đã thay đổi gì so với bản gốc

| File | Thay đổi | Vì sao |
|---|---|---|
| `engine/Engine.h` | Thêm khai báo `requestCapitalizeNextChar()` | Hàm mới để yêu cầu viết hoa ký tự tiếp theo |
| `engine/Engine.cpp` | Thêm hàm `requestCapitalizeNextChar()`, gọi trong `vKeyInit()` | Đặt trạng thái "sẵn sàng viết hoa" ngay khi engine khởi tạo |
| `macOS/ModernKey/OpenKey.mm` | Gọi `requestCapitalizeNextChar()` trong `RequestNewSession()` (khi phát hiện **click chuột**) | Click chuột = dấu hiệu bắt đầu gõ vào ô mới → ký tự tiếp theo sẽ tự viết hoa |
| `macOS/ModernKey/MJAccessibilityUtils.m` | Bỏ đường gọi hàm `AXAPIEnabled()` đã cũ | Hàm này đã bị Apple gỡ khỏi SDK macOS mới, không compile được nữa |
| `macOS/OpenKey.xcodeproj/project.pbxproj` | Bỏ bước nhúng `OpenKeyUpdate.app` khỏi target chính `OpenKey` | Thư mục `OpenKeyUpdate` (bộ tự cập nhật) bị thiếu file trong gói mã nguồn tải từ GitHub, không build được |

**Đánh đổi cần biết:** vì OpenKey không đọc nội dung ô văn bản để biết ô đó có đang trống hay không, cơ chế mới dùng "click chuột" làm tín hiệu bắt đầu phiên gõ mới. Hệ quả: nếu bạn click vào **giữa** một đoạn văn bản có sẵn để sửa (không phải ô trống), ký tự gõ tiếp theo cũng sẽ bị viết hoa nhầm.

**Tính năng bị bỏ:** OpenKeyUpdate (tự kiểm tra bản cập nhật) không được build cùng, vì bản mã nguồn tải từ GitHub thiếu file resource của module này. Không ảnh hưởng đến việc gõ tiếng Việt.

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
6. Nếu tiến trình nền `OpenKeyHelper` chưa tự chạy: vào OpenKey, tắt rồi bật lại tùy chọn "Chạy cùng khởi động máy" để kích hoạt.

## 5. Lưu ý khi chia sẻ cho người khác (giấy phép GPLv3)

OpenKey phát hành theo giấy phép **GPLv3** (xem `Source/LICENSE`). Điều đó có nghĩa là khi chia sẻ bản đã sửa này cho người khác, bạn **bắt buộc**:

- Kèm theo mã nguồn (thư mục `Source/` này) — đã có sẵn trong gói.
- Ghi rõ đây là bản chỉnh sửa dựa trên OpenKey gốc: <https://github.com/tuyenvm/OpenKey>.
- Giữ nguyên giấy phép GPLv3 cho bản phân phối lại.

Gói `DinhPhuu_KEY` này đã tuân thủ đủ các điều trên.
