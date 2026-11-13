#include "lyricmodel.h"

#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QRegularExpression>
#include <QUrl>

#include <algorithm>

LyricModel::LyricModel(QObject *parent)
    : QAbstractListModel{parent}
{
}

int LyricModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_lines.size();
}

QVariant LyricModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_lines.size())
        return QVariant();
    const Line &line = m_lines.at(index.row());
    switch (role) {
    case TimeRole:
        return line.time;
    case TextRole:
        return line.text;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> LyricModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TimeRole] = "time";
    roles[TextRole] = "text";
    return roles;
}

bool LyricModel::looksLikeLyricText(const QString &text)
{
    return text.contains(QLatin1Char('[')) && text.contains(QLatin1Char(']'));
}

QVector<LyricModel::Line> LyricModel::parseContent(const QString &content)
{
    QVector<Line> out;
    // 兼容 \r\n / \r / \n
    const QStringList rawLines = content.split(QRegularExpression(QStringLiteral("[\\r\\n]+")),
                                               Qt::SkipEmptyParts);
    static const QRegularExpression timeTag(
        QStringLiteral("\\[(\\d{1,3}):(\\d{1,2})(?:[.:](\\d{1,3}))?\\]"));

    for (const QString &raw : rawLines) {
        const QString line = raw.trimmed();
        if (line.isEmpty())
            continue;
        if (line.startsWith(QLatin1Char('{'))) {
            QJsonParseError err;
            const QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8(), &err);
            if (err.error == QJsonParseError::NoError && doc.isObject()) {
                const QJsonObject obj = doc.object();
                const int t = obj.value(QStringLiteral("t")).toInt(-1);
                QString text;
                const QJsonArray parts = obj.value(QStringLiteral("c")).toArray();
                for (const QJsonValue &v : parts) {
                    if (v.isObject())
                        text += v.toObject().value(QStringLiteral("tx")).toString();
                }
                text = text.trimmed();
                if (t >= 0 && !text.isEmpty())
                    out.append(Line{t, text});
            }
            continue;
        }
        QVector<int> times;
        int textStart = -1;
        QRegularExpressionMatchIterator it = timeTag.globalMatch(line);
        while (it.hasNext()) {
            const QRegularExpressionMatch m = it.next();
            const int minutes = m.captured(1).toInt();
            const int seconds = m.captured(2).toInt();
            const QString frac = m.captured(3);
            int milli = 0;
            if (!frac.isEmpty()) {
                if (frac.size() == 1)
                    milli = frac.toInt() * 100;
                else if (frac.size() == 2)
                    milli = frac.toInt() * 10;
                else
                    milli = frac.left(3).toInt();
            }
            times.append((minutes * 60 + seconds) * 1000 + milli);
            textStart = m.capturedEnd();
        }
        if (times.isEmpty() || textStart < 0)
            continue;

        const QString text = line.mid(textStart).trimmed();
        if (text.isEmpty())
            continue;
        for (int t : times)
            out.append(Line{t, text});
    }

    std::stable_sort(out.begin(), out.end(),
                     [](const Line &a, const Line &b) { return a.time < b.time; });

    QVector<Line> unique;
    unique.reserve(out.size());
    for (const Line &line : out) {
        if (!unique.isEmpty() && unique.last().time == line.time
            && unique.last().text == line.text)
            continue;
        unique.append(line);
    }
    return unique;
}

bool LyricModel::loadFile(const QString &source)
{
    QString src = source.trimmed();
    if (src.startsWith(QStringLiteral("file://")))
        src = QUrl(src).toLocalFile();

    QVector<Line> parsed;
    QString error;
    bool ok = false;

    if (src.isEmpty()) {
        error = QStringLiteral("这首歌曲暂时还没有歌词");
    } else {
        QString content;
        if (QFileInfo::exists(src)) {
            QFile file(src);
            if (file.open(QIODevice::ReadOnly)) {
                QByteArray data = file.readAll();
                if (data.startsWith("\xEF\xBB\xBF"))
                    data.remove(0, 3);
                content = QString::fromUtf8(data);
            } else {
                error = QStringLiteral("歌词文件打不开：%1").arg(file.errorString());
            }
        } else if (looksLikeLyricText(src)) {
            content = src;
        } else {
            error = QStringLiteral("歌词文件不存在");
        }

        if (!content.isEmpty()) {
            parsed = parseContent(content);
            ok = !parsed.isEmpty();
            if (!ok)
                error = QStringLiteral("歌词内容为空或格式无法识别");
        } else if (error.isEmpty()) {
            error = QStringLiteral("这首歌曲暂时还没有歌词");
        }
    }

    beginResetModel();
    m_lines = parsed;
    m_loaded = ok;
    m_error = error;
    m_loadedSource = src;
    endResetModel();

    emit countChanged();
    emit loadedChanged();
    return ok;
}

void LyricModel::clear()
{
    beginResetModel();
    m_lines.clear();
    m_loaded = false;
    m_error.clear();
    m_loadedSource.clear();
    endResetModel();

    emit countChanged();
    emit loadedChanged();
}

int LyricModel::indexAt(int positionMs) const
{
    if (m_lines.isEmpty())
        return -1;
    if (positionMs < m_lines.first().time)
        return -1;

    int low = 0;
    int high = m_lines.size() - 1;
    int answer = 0;
    while (low <= high) {
        const int mid = low + (high - low) / 2;
        if (m_lines.at(mid).time <= positionMs) {
            answer = mid;
            low = mid + 1;
        } else {
            high = mid - 1;
        }
    }
    return answer;
}
