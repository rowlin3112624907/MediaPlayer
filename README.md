# MediaPlayer

用 **Qt 6 / QML** 写的桌面音乐播放器：无边框窗口 + 黑洞粒子背景 + 手写体开机动画 + 逐行滚动歌词 + MySQL 歌单。

![开机动画：逐笔手写 Rowl.](docs/screenshots/boot.jpg)

![主界面：歌单 / 推荐卡片 / 歌曲列表 / 歌词面板 / 播放条](docs/screenshots/main.jpg)

> 个人练习项目（v0.1）。在 Windows 11 + Qt 6.11.1 (MSVC 2022 64bit) 上实际编译、运行验证过。

## 功能

- **开机动画**：`qml/Ai_RowlinBootAnimation.qml` 用 Canvas 逐笔绘制 "Rowl."，笔画带发光，画完停留、淡出，然后切换到主界面
- **粒子背景**：`qml/Flowing.qml` 双 ParticleSystem + 自定义涡旋 Affector，20 秒一个循环
- **歌单 / 歌曲列表**：左侧 10 个歌单（歌曲数据来自 MySQL），点击查歌；中间列表显示歌名与歌手
- **推荐卡片**：顶部横向卡片，随播放进度自动滚动，手动拖动后 4 秒恢复跟随
- **播放条**：播放 / 暂停、音量、进度拖动、上一首 / 下一首、当前曲目
- **歌词面板**：解析 `.lrc`，当前句随机高亮、自动居中、点击放大、可用文件对话框更换背景图
- **无边框窗口**：`Qt.FramelessWindowHint`，右上角是关闭按钮

## 技术栈

| 项目 | 说明 |
| --- | --- |
| 框架 | Qt 6.5+（Quick、QuickControls2、Multimedia、Sql、Quick.Particles、Quick.Effects、Quick.Dialogs） |
| 语言 | C++17 |
| 构建 | CMake ≥ 3.21；也可以用 Qt Creator 直接打开根目录的 `CMakeLists.txt` |
| 数据库 | MySQL 5.7 / 8.x + `QMYSQL` 驱动 |
| 编译器 | MSVC 2022（作者环境）；MinGW 理论上也可 |

> Qt 版本必须是 **6.5 或更高**：推荐卡片用了 `QtQuick.Effects` 的 `MultiEffect`（Qt 6.5 才有的 QML 模块）。

## 目录结构

```text
MediaPlayer/
├── CMakeLists.txt
├── myplaylist.h            # QAbstractListModel：连接 MySQL，加载歌单歌曲、上一首/下一首
├── lyricmodel.h            # QAbstractListModel：解析 .lrc，按毫秒定位当前行
├── qml/                    # 全部界面
│   ├── main.qml            # 窗口根节点 + Loader 切换「开机动画 / 主界面」
│   ├── Ai_RowlinBootAnimation.qml   # 手写体开机动画
│   ├── Flowing.qml                 # 粒子背景
│   ├── PlayList_Listmodel.qml      # 左侧 10 个歌单
│   ├── SongListview.qml            # 中间歌曲列表
│   ├── CoreWindow.qml              # 顶部推荐卡片
│   ├── Mul_media_mp3.qml           # 底部播放条
│   ├── LyricsPanel.qml             # 右侧歌词面板
│   └── BootAnimation.qml           # 早期版本遗留，当前未使用
├── rsc/                    # C++ 源码
│   ├── main.cpp            # 入口：数据库连接、模型注入、加载 QML
│   ├── myplaylist.cpp
│   └── lyricmodel.cpp
├── assent/image/           # 图标资源（QML 里以 "./xxx.png" 相对路径引用）
├── sql/schema.sql          # 建库建表脚本
└── docs/screenshots/       # README 用的截图
```

## 构建

```bash
git clone https://github.com/rowlin3112624907/MediaPlayer.git
cd MediaPlayer
cmake -S . -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.11.1/msvc2022_64"
cmake --build build --config Release
```

产物是 `build/appMediaPlayer.exe`。直接双击运行需要 Qt 的 `bin` 目录在 `PATH` 里，否则会缺 DLL；想打包成绿色版可以：

```bash
windeployqt --qmldir qml build/appMediaPlayer.exe
```

> 这是 `WIN32` 程序（没有控制台窗口），`qDebug` 输出不会显示在终端里。排查问题请在 Qt Creator 的「应用程序输出」里看，或用 DebugView 之类的工具。

## 数据库

先执行建表脚本：

```bash
mysql -u root -p < sql/schema.sql
```

连接参数在 `rsc/main.cpp` 里读环境变量，没设置时用默认值（127.0.0.1:3306 / root / 空密码 / mymusic）。PowerShell 里可以这样启动：

```powershell
$env:MP_SQL_USER = "root"
$env:MP_SQL_PASSWORD = "你的密码"
$env:MP_SQL_DATABASE = "mymusic"
.\build\appMediaPlayer.exe
```

| 环境变量 | 默认值 | 说明 |
| --- | --- | --- |
| `MP_SQL_DRIVER` | `QMYSQL` | 驱动名，没装 MySQL 驱动会连不上 |
| `MP_SQL_HOST` | `127.0.0.1` | 主机 |
| `MP_SQL_PORT` | `3306` | 端口 |
| `MP_SQL_USER` | `root` | 用户名 |
| `MP_SQL_PASSWORD` | 空 | 密码 |
| `MP_SQL_DATABASE` | `mymusic` | 库名 |

三张表（详见 `sql/schema.sql`）：

- `song`：歌曲信息，`audiopath` 是 mp3 的**本机绝对路径**，`lrc` 是歌词文件路径
- `playlist_index`：歌单表，id 1~10 对应界面上写死的 10 个歌单
- `playlist_song`：歌单与歌曲的关联，`sort_order` 控制列表顺序

> 仓库里**不包含任何音频文件**（版权原因）。数据库里的 `audiopath` / `lrc` 填你自己电脑上的文件路径，例如 `D:/Music/xxx.mp3`。

## 歌词

- 支持标准 LRC：`[mm:ss.xx]歌词`，一行可以写多个时间标签
- 也兼容 `{"t": 12345, "c": [{"tx": "..."}]}` 这种逐行 JSON 格式（部分第三方歌词源）
- 只按 **UTF-8** 读取，GBK 编码的 `.lrc` 会乱码
- 暂不支持 `[offset:±ms]`、`[ti:]` 之类的标签会被当作普通文本跳过
- `lrc` 字段建议填绝对路径；相对路径会按进程工作目录解析

## 已知问题 / 待办

- 顶部 8 张推荐卡片和歌词面板的默认背景写死成了作者本机的路径（`D:/steam/steamapps/workshop/...`），别人运行会是空白；换成自己的图片、或者删掉这些路径用纯色/渐变都行
- 无边框窗口还没有实现拖动（`Qt.FramelessWindowHint` 之后没有拖拽区域），关闭按钮位置也是按 1500×900 写死的
- 点击歌曲时 `main.qml` 的 `onPlaySong` 和 `myplaylist` 的 `audioPathChanged` 都会触发播放，理论上会重复调用一次 `play()`
- 换歌时「上一首」在还没选过歌的情况下会绕到最后一首
- 需要本地 MySQL，列表为空时说明数据库没连上 / 没建表 / 没有插入数据
- 只在 Windows + MSVC 上验证过；Linux 上注意 QML 文件名大小写
- `qml/BootAnimation.qml` 是早期版本遗留，当前没有被使用，可以删除

## 致谢与许可

- 图标素材来自阿里云矢量图库等公开资源；截图中的壁纸与封面来自 Wallpaper Engine 创意工坊，仅用于界面演示，版权归原作者所有，仓库中的截图如涉及版权请自行替换
- 本项目代码以 **MIT** 协议开源，详见 [LICENSE](LICENSE)
- Qt 本身以 **LGPLv3** 授权（本项目为动态链接使用），商用/分发时请遵守 Qt 的许可协议
