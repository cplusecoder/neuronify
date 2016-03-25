#ifndef VIBRATORENGINE_H
#define VIBRATORENGINE_H

#include "../core/nodeengine.h"

#if defined(Q_OS_ANDROID)
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#endif

class VibratorEngine : public NodeEngine
{
    Q_OBJECT
public:
    VibratorEngine(QQuickItem *parent = 0);
    void vibrate();

protected:
    virtual void receiveFireEvent(double fireOutput, NodeEngine *sender) override;

private:
#if defined(Q_OS_ANDROID)
    QAndroidJniObject m_vibratorService;
#endif
};

#endif // VIBRATORENGINE_H
