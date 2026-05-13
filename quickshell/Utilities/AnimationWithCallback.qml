import QtQuick

Item {
    id: helper
    
    signal finished()

    function start(target, property, to, duration) {
        anim.target = target;
        anim.property = property;
        anim.to = to;
        anim.duration = duration;
        anim.restart();
    }

    NumberAnimation {
        id: anim
        easing.type: Easing.OutCubic
        onStopped: helper.finished()
    }
}