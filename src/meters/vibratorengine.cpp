#include "vibratorengine.h"

VibratorEngine::VibratorEngine(QQuickItem *parent)
    : NodeEngine(parent)
{
#if defined(Q_OS_ANDROID)
    QAndroidJniObject vibratorString = QAndroidJniObject::fromString("vibrator");
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    QAndroidJniObject context = activity.callObjectMethod("getApplicationContext","()Landroid/content/Context;");
    m_vibratorService = context.callObjectMethod("getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;", vibratorString.object<jstring>());
#endif
}

void VibratorEngine::vibrate() {
#if defined(Q_OS_ANDROID)
    if (m_vibratorService.isValid()) {
        qDebug() << "Vibrate!";
        m_vibratorService.callMethod<void>("vibrate", "(J)V", 1000);
    } else {
        qDebug() << "Not valid vibrator service";
    }
#endif
}


void VibratorEngine::receiveFireEvent(double fireOutput, NodeEngine *sender)
{
    Q_UNUSED(fireOutput);
    Q_UNUSED(sender);
    vibrate();
}
