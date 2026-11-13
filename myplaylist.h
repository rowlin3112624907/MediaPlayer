#ifndef MYPLAYLIST_H
#define MYPLAYLIST_H

#include <QObject>
#include<QSqlDatabase>
#include<QSqlError>
#include<QSqlQuery>
#include<QDebug>
#include<QAbstractListModel>
struct Song{
    QString title;
    QString artist;
    int duration;
    QString audiopath;
    QString lrcpath;
};

class MyplayList : public QAbstractListModel
{
    Q_OBJECT
    enum SongRole {
        TitleRole = Qt::UserRole + 1,
        ArtistRole,
        DurationRole,
        AudioPathRole,
        LrcPathRole
    };
public:
    explicit MyplayList(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE void loadSongs(int playlistId);
    Q_INVOKABLE void nextsong();
    Q_INVOKABLE void presong();
    Q_INVOKABLE void setCurrentpath(int index);

    Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY currentSongChanged)
    Q_PROPERTY(QString currentArtist READ currentArtist NOTIFY currentSongChanged)
    Q_PROPERTY(QString currentLrcPath READ currentLrcPath NOTIFY currentSongChanged)
    QString currentTitle() const;
    QString currentArtist() const;
    QString currentLrcPath() const;

    void setDb(QSqlDatabase db);
signals:
    void audioPathChanged(QString path);
    void currentSongChanged();
private:
    QVector<Song> m_songs;
    QSqlDatabase db;
    int m_currentpath=-1;
};

#endif // MYPLAYLIST_H
