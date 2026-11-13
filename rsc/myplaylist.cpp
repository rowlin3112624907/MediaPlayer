#include "myplaylist.h"

MyplayList::MyplayList(QObject *parent)
    : QAbstractListModel{parent}
{
    // QSqlDatabase db= QSqlDatabase::addDatabase("QMYSQL");
    // db.setHostName("127.0.0.1");
    // db.setPort(3306);
    // db.setUserName("root");
    // db.setPassword("53770pzf");
    // db.setDatabaseName("mymusic");
    // if(!db.open()){
    //     qDebug()<<"数据库打开失败"<<db.lastError().text();
    // }
}
int MyplayList::rowCount(const QModelIndex &parent) const
{if(parent.isValid())
        return 0;
    return m_songs.size();
}
QVariant MyplayList::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()||index.row()>=m_songs.size()){
        return QVariant();
    }
    const Song&song=m_songs.at(index.row());
    switch (role) {
    case TitleRole:return song.title;break;
    case ArtistRole:return song.artist;break;
    case DurationRole:return song.duration;break;
    case AudioPathRole:return song.audiopath;break;
    case LrcPathRole:return song.lrcpath;break;
    default:
        return QVariant();
        break;
    }

}

QHash<int, QByteArray> MyplayList::roleNames() const
{
    QHash<int,QByteArray>roles;
    roles[TitleRole]="title";
    roles[ArtistRole]="artist";
    roles[DurationRole]="duration";
    roles[AudioPathRole]="audiopath";
    roles[LrcPathRole]="lrcpath";
    return roles;
}

void MyplayList::loadSongs(int playlistId)
{
    beginResetModel();
    m_songs.clear();
    QSqlQuery query(db);
    if(!query.prepare("select s.title,s.artist,s.duration,s.audiopath,s.lrc from song s "
                      "join playlist_song ps on s.id = ps.song_id "
                      "where ps.playlist_id = ? order by ps.sort_order")){
        qDebug()<<"歌曲查询准备失败"<<query.lastError().text();
        endResetModel();
        return;
    }
    query.addBindValue(playlistId);
    if(!query.exec()){
        qDebug()<<"歌曲查询失败"<<query.lastError().text();
        endResetModel();
        return;
    }
    while(query.next()){
        Song s;
        s.title=query.value("title").toString();
        s.artist=query.value("artist").toString();
        s.duration=query.value("duration").toInt();
        s.audiopath=query.value("audiopath").toString();
        s.lrcpath=query.value("lrc").toString();
        m_songs.append(s);
    }
    if (m_currentpath >= m_songs.size())
        m_currentpath = -1;
    endResetModel();
    emit currentSongChanged();
}

void MyplayList::nextsong()
{
    if(m_songs.isEmpty())
        return;
    const int size = m_songs.size();
    const int start = (m_currentpath < 0) ? -1 : m_currentpath;   // 还没选过歌时从第 0 首开始
    for (int i = 1; i <= size; ++i) {
        int index = (start + i) % size;
        if (index < 0)
            index += size;
        if (!m_songs.at(index).audiopath.isEmpty()) {
            setCurrentpath(index);
            return;
        }
    }
}
void MyplayList::presong()
{
    if(m_songs.isEmpty())
        return;
    const int size = m_songs.size();
    const int start = (m_currentpath < 0) ? 0 : m_currentpath;
    for (int i = 1; i <= size; ++i) {
        int index = ((start - i) % size + size) % size;
        if (!m_songs.at(index).audiopath.isEmpty()) {
            setCurrentpath(index);
            return;
        }
    }
}

void MyplayList::setCurrentpath(int index)
{
        if(index <0 || index >= m_songs.size())
            return;
        m_currentpath = index;
        emit audioPathChanged(m_songs[index].audiopath);
        emit currentSongChanged();
}

QString MyplayList::currentTitle() const
{
    if (m_currentpath < 0 || m_currentpath >= m_songs.size())
        return QString();
    return m_songs.at(m_currentpath).title;
}

QString MyplayList::currentArtist() const
{
    if (m_currentpath < 0 || m_currentpath >= m_songs.size())
        return QString();
    return m_songs.at(m_currentpath).artist;
}

QString MyplayList::currentLrcPath() const
{
    if (m_currentpath < 0 || m_currentpath >= m_songs.size())
        return QString();
    return m_songs.at(m_currentpath).lrcpath;
}



void MyplayList::setDb(QSqlDatabase db) {
    this->db = db;
    if (!db.isOpen()) {
        qDebug() << "传入的数据库未打开:" << db.lastError().text();
    }
}
