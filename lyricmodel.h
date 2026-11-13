#ifndef LYRICMODEL_H
#define LYRICMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QString>
#include <QVector>


class LyricModel : public QAbstractListModel
{
    Q_OBJECT
    enum LyricRole {
        TimeRole = Qt::UserRole + 1,
        TextRole
    };
public:
    explicit LyricModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool loadFile(const QString &source);
    Q_INVOKABLE void clear();
    Q_INVOKABLE int indexAt(int positionMs) const;

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool loaded READ loaded NOTIFY loadedChanged)
    Q_PROPERTY(QString errorText READ errorText NOTIFY loadedChanged)
    Q_PROPERTY(QString loadedSource READ loadedSource NOTIFY loadedChanged)

    int count() const { return m_lines.size(); }
    bool loaded() const { return m_loaded; }
    QString errorText() const { return m_error; }
    QString loadedSource() const { return m_loadedSource; }

signals:
    void countChanged();
    void loadedChanged();

private:
    struct Line {
        int time = 0;   // 毫秒
        QString text;
    };

    static QVector<Line> parseContent(const QString &content);
    static bool looksLikeLyricText(const QString &text);

    QVector<Line> m_lines;
    bool m_loaded = false;
    QString m_error;
    QString m_loadedSource;
};

#endif // LYRICMODEL_H
