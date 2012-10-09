
#pragma once

#include <qfont.h>
#include <qfontinfo.h>
#include <qfontmetrics.h>

#include <QtScript/qscriptvalue.h>
#include <QtScript/QScriptEngine>

Q_DECLARE_METATYPE(QFontInfo)
Q_DECLARE_METATYPE(QFontMetrics)
Q_DECLARE_METATYPE(QFontMetricsF)



template <>
inline void *qMetaTypeCreateHelper<QFontInfo>(const void *t)
{
    if (t)
        return new QFontInfo(*static_cast<const QFontInfo*>(t));
    return new QFontInfo(QFont());
}

template <>
inline void *qMetaTypeConstructHelper<QFontInfo>(void *where, const void *t)
{
    if (t)
        return new (where) QFontInfo(*static_cast<const QFontInfo*>(t));
    return new (where) QFontInfo(QFont());
}

template <>
inline QFontInfo qscriptvalue_cast<QFontInfo>(const QScriptValue &value)
{
    QFont f;
    QFontInfo t(f);
    const int id = qMetaTypeId<QFontInfo>();

    if (qscriptvalue_cast_helper(value, id, (void*)&t))
        return t;

    return QFontInfo(QFont());
}





template <>
inline void *qMetaTypeCreateHelper<QFontMetrics>(const void *t)
{
    if (t)
        return new QFontMetrics(*static_cast<const QFontMetrics*>(t));
    return new QFontMetrics(QFont());
}

template <>
inline void *qMetaTypeConstructHelper<QFontMetrics>(void *where, const void *t)
{
    if (t)
        return new (where) QFontMetrics(*static_cast<const QFontMetrics*>(t));
    return new (where) QFontMetrics(QFont());
}

template <>
inline QFontMetrics qscriptvalue_cast<QFontMetrics>(const QScriptValue &value)
{
    QFont f;
    QFontMetrics t(f);
    const int id = qMetaTypeId<QFontMetrics>();

    if (qscriptvalue_cast_helper(value, id, (void*)&t))
        return t;

    return QFontMetrics(QFont());
}




template <>
inline void *qMetaTypeCreateHelper<QFontMetricsF>(const void *t)
{
    if (t)
        return new QFontMetricsF(*static_cast<const QFontMetricsF*>(t));
    return new QFontMetricsF(QFont());
}

template <>
inline void *qMetaTypeConstructHelper<QFontMetricsF>(void *where, const void *t)
{
    if (t)
        return new (where) QFontMetricsF(*static_cast<const QFontMetricsF*>(t));
    return new (where) QFontMetricsF(QFont());
}

template <>
inline QFontMetricsF qscriptvalue_cast<QFontMetricsF>(const QScriptValue &value)
{
    QFont f;
    QFontMetricsF t(f);
    const int id = qMetaTypeId<QFontMetricsF>();

    if (qscriptvalue_cast_helper(value, id, (void*)&t))
        return t;

    return QFontMetricsF(QFont());
}
