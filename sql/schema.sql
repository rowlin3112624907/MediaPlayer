-- MediaPlayer 建库建表脚本（MySQL 5.7 / 8.x）
-- 用法：mysql -u root -p < sql/schema.sql
-- 注意：本仓库不包含任何音频文件，song.audiopath / song.lrc 请填你本机的绝对路径。

CREATE DATABASE IF NOT EXISTS mymusic
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
USE mymusic;

-- 歌曲表
CREATE TABLE IF NOT EXISTS song (
    id        INT           NOT NULL AUTO_INCREMENT,
    title     VARCHAR(100)  NOT NULL COMMENT '歌名',
    artist    VARCHAR(50)   DEFAULT '未知歌手' COMMENT '歌手',
    duration  INT           DEFAULT 0 COMMENT '时长（秒，目前仅用于展示）',
    audiopath VARCHAR(200)  DEFAULT NULL COMMENT '本机 mp3 绝对路径，例如 D:/Music/a.mp3',
    lrc       VARCHAR(1000) DEFAULT NULL COMMENT '本机 .lrc 绝对路径，留空则显示「没有歌词」',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 歌单表（界面左侧 10 个歌单的名字写死在 qml/PlayList_Listmodel.qml，
-- 这里只需要 id 1~10 存在，并且 playlist_song 里有对应的关联数据）
CREATE TABLE IF NOT EXISTS playlist_index (
    id   INT         NOT NULL AUTO_INCREMENT,
    name VARCHAR(20) DEFAULT NULL COMMENT '歌单名',
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 歌单与歌曲的关联表
CREATE TABLE IF NOT EXISTS playlist_song (
    id          INT NOT NULL AUTO_INCREMENT,
    playlist_id INT NOT NULL,
    song_id     INT NOT NULL,
    sort_order  INT DEFAULT 0 COMMENT '歌单内的显示顺序',
    PRIMARY KEY (id),
    KEY fk_ps_playlist (playlist_id),
    KEY fk_ps_song (song_id),
    CONSTRAINT fk_ps_playlist FOREIGN KEY (playlist_id) REFERENCES playlist_index (id) ON DELETE CASCADE,
    CONSTRAINT fk_ps_song FOREIGN KEY (song_id) REFERENCES song (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 界面左侧固定 10 个歌单，先把 1~10 号歌单建好
INSERT INTO playlist_index (id, name) VALUES
    (1,  '我喜欢的'),
    (2,  '我不喜欢的'),
    (3,  '许愿十二点之前睡着'),
    (4,  'ta喜欢的'),
    (5,  'ta很喜欢的'),
    (6,  'ta狠狠喜欢的'),
    (7,  '你和我喜欢的'),
    (8,  'ta和我喜欢的'),
    (9,  '你我都不喜欢的'),
    (10, '你喜欢的')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- ============ 示例数据（按需取消注释并换成你自己的文件路径） ============
-- INSERT INTO song (title, artist, duration, audiopath, lrc) VALUES
--     ('示例歌曲', '示例歌手', 240, 'D:/Music/demo.mp3', 'D:/Music/demo.lrc');
-- INSERT INTO playlist_song (playlist_id, song_id, sort_order) VALUES (1, 1, 0);
