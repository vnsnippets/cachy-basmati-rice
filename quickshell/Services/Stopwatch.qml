pragma Singleton
import QtQuick

QtObject {
    id: root

    // This is the blueprint for the timer
    property Component _timer_component: Component {
        Timer {
            repeat: false
            property var _callback: null

            onTriggered: {
                if (root && _callback) _callback();
                _callback = null;
                this.destroy(); 
            }

            function begin(delay, cb) {
                stop();
                interval = delay;
                _callback = cb;
                start();
            }

            function end() {
                stop();
                _callback = null;
            }
        }
    }

    // This creates and returns a UNIQUE instance
    function create(parent_obj) {
        return _timer_component.createObject(parent_obj);
    }
}