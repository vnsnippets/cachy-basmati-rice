pragma Singleton
import QtQuick

QtObject {
    id: root

    // This is the blueprint for the timer
    property Component _timer_component: Component {
        Timer {
            repeat: false

            property bool _autoDestroy: true
            property var _callback: null

            onTriggered: {
                if (root && _callback) _callback();
                
                if (!repeat && _autoDestroy) {
                    _callback = null;
                    this.destroy(); 
                }
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
                if (!repeat) this.destroy();
            }
        }
    }

    // This creates and returns a UNIQUE instance
    function create(parent_obj, repeat, autoDestroy) {
        return _timer_component.createObject(parent_obj, {
            "repeat": repeat,
            "_autoDestroy": autoDestroy
        });
    }
}