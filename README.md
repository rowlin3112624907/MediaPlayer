# MediaPlayer
one mediaplayer

一个用 **Qt 6 + QML** 写的桌面音乐播放器 Demo：无边框窗口 + 粒子背景 + 逐笔手写启动动画 + 逐行滚动歌词 + MySQL 歌单。

> 状态：个人练习项目（v0.1），仅在 **Windows 11 + Qt 6.11.1 + MSVC 2022 64bit** 上验证过。

|启动动画|

|播放器界面|

```

```

## 功能

- 无边框黑底窗口，开机手写动画（`Ai_RowlinBootAnimation.qml`）结束后切入主界面
- 全屏黑洞粒子背景（`flowing.qml`，双 ParticleSystem + 自定义涡旋 Affector，20s 循环）
- 左侧 10 个歌单，点击从 MySQL 查歌；中间歌曲列表；横向推荐卡片（随播放进度自动滑动）
- 底部播放条：播放/暂停、音量、进度拖动、上/下一首、当前曲目信息
- 右侧歌词面板：`.lrc` 解析、当前句随机高亮、自动居中、点击放大、可换背景图

## 环境要求

| Qt | **>= 6.5**（用了 `QtQuick.Effects` 的 `MultiEffect`） |
| 模块 | Quick / Controls / Multimedia / SQL / Quick.Particles / Quick.Effects / Quick.Dialogs |
| 编译器 | MSVC 2022 或 MinGW（C++17） |
| CMake | >= 3.16 |
| 数据库 | MySQL 5.7/8.x + **QMYSQL 驱动**（Qt 官方安装包不带，需自行编译） |

## 构建

```bash
git clone https://github.com/<your-name>/qml_music.git
cd qml_music
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.11.1/msvc2022_64"
cmake --build build --config Release
```

或用 Qt Creator 直接打开根目录的 `CMakeLists.txt`。

## 数据库

执行 `sql/schema.sql` 建库建表，再在 `main.cpp` 里填上你的连接信息（或改成环境变量）：

！！自行建库，由于涉及版权问题

歌曲/歌词路径写数据库里的 `audiopath` / `lrc` 字段，指向**你本机**的 mp3 与 .lrc 文件。

## 已知限制

- 推荐卡片与歌词背景的图片路径写死在 `main.qml` / `LyricsPanel.qml` 里，首次运行是空白或裂图，自行替换成本地图片
- 需要本地 MySQL，否则歌曲列表为空（无内嵌播放器/无在线源）
- 目前只在 Windows + MSVC 上验证；Linux 需注意 QML 文件名大小写

## 致谢与许可
-图片来源：阿里云矢量图库、Wallpaper
- 本项目代码以 `MIT` 协议开源；Qt 本身以 LGPLv3 授权使用，详见 LICENSE
