pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // FontLoader {
    //     id: customFont
    //     source: "../Assets/IosevkaCharon-Regular.ttf"
    // }

    readonly property string namespace: "quickshell-basmati"

    readonly property QtObject colors: QtObject {
        readonly property color rosewater: "#f5e0dc"
        readonly property color flamingo: "#f2cdcd"
        readonly property color pink: "#f5c2e7"
        readonly property color mauve: "#cba6f7"
        readonly property color red: "#f38ba8"
        readonly property color maroon: "#eba0ac"
        readonly property color peach: "#fab387"
        readonly property color yellow: "#f9e2af"
        readonly property color green: "#a6e3a1"
        readonly property color teal: "#94e2d5"
        readonly property color sky: "#89dceb"
        readonly property color sapphire: "#74c7ec"
        readonly property color blue: "#89b4fa"
        readonly property color lavender: "#b4befe"

        readonly property color text: "#cdd6f4"
        // readonly property color subtext1: "#bac2de"
        readonly property color subtext: "#a6adc8"
        // readonly property color overlay2: "#9399b2"
        // readonly property color overlay1: "#7f849c"
        readonly property color overlay: "#6c7086"
        // readonly property color surface2: "#585b70"
        // readonly property color surface1: "#45475a"
        readonly property color surface: "#313244"
        readonly property color base: "#1e1e2e"
        readonly property color mantle: "#181825"
        readonly property color crust: "#11111b"
    }

    // Padding is determined based on roundness
    // The more rounded a component, the more padding
    // Roundness is a ratio ranging from zero to a maximum
    property real roundness: 0.5
    readonly property int maxradius: 24
    readonly property int radius: roundness * maxradius
    readonly property int padding: 10

    readonly property int spacing: 8
    readonly property int gap: 8 // Matches gaps in compositor configurations
 
    // Default size (height in most cases, but width as well for icon buttons)
    readonly property int size: 40

    readonly property QtObject font: QtObject {
        readonly property int size: 14
        readonly property string family: "Noto Sans" // customFont.name
    }

    readonly property QtObject dashboard: QtObject {
        readonly property int width: 720
        readonly property int animduration: 150
    }
    
    readonly property QtObject applications: QtObject {
        readonly property int width: 720
        readonly property int height: 500

        readonly property QtObject searchbox: QtObject {
            readonly property color background: Styles.colors.base
            
            readonly property QtObject border: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.overlay, 0)
                readonly property color active: Qt.alpha(Styles.colors.overlay, 0.4)
            }
            readonly property color text: Styles.colors.text
            readonly property string placeholder: "Search..."
            readonly property string icon: "search.svg"
        }

        readonly property QtObject item: QtObject {
            readonly property int height: Styles.size

            readonly property QtObject background: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.surface, 0)
                readonly property color active: Qt.alpha(Styles.colors.surface, 0.3)
            }
            readonly property QtObject border: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.overlay, 0)
                readonly property color active: Qt.alpha(Styles.colors.overlay, 0.3)
            }
            readonly property QtObject text: QtObject {
                readonly property color idle: Styles.colors.subtext
                readonly property color active: Styles.colors.text
            }
        }
    }

    readonly property QtObject audio: QtObject {
        readonly property QtObject osd: QtObject {
            readonly property int width: 320
            readonly property int padding: 14
            readonly property int offsetvertical: 48
            readonly property int activetimeout: 2000

            readonly property QtObject border: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.subtext, 0.25)
                readonly property color active: Qt.alpha(Styles.colors.subtext, 0.40)
            }

            readonly property QtObject background: QtObject {
                readonly property color idle: Styles.colors.mantle
                readonly property color active: Styles.colors.mantle
            }
        }

        readonly property QtObject device: QtObject {
            readonly property QtObject background: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.surface, 0.4)
                readonly property color active: Qt.alpha(Styles.colors.green, 1)
            }
            readonly property QtObject text: QtObject {
                readonly property color idle: Styles.colors.text
                readonly property color active: Styles.colors.base
            }
        }

        readonly property QtObject slide: QtObject {
            readonly property QtObject icon: QtObject {
                readonly property int size: Styles.size - Styles.padding * 2
                readonly property color idle: Styles.colors.text
                readonly property color active: Styles.colors.text
            }

            readonly property QtObject track: QtObject {
                readonly property int height: 12
                readonly property int width: 240
                readonly property color idle: Qt.alpha(Styles.colors.text, 0.1)
                readonly property color active: Styles.colors.green

                readonly property QtObject handle: QtObject {
                    readonly property color border: Styles.colors.green
                    readonly property color color: Styles.colors.green
                }
            }

            readonly property color text: Styles.colors.text
        }
    }

    readonly property QtObject brightness: QtObject {
        readonly property QtObject slide: QtObject {
            readonly property color background: Qt.alpha(Styles.colors.base, 0)
            readonly property color text: Styles.colors.text

            readonly property QtObject icon: QtObject {
                readonly property int size: Styles.size - Styles.padding * 2
                readonly property color color: Styles.colors.text
            }

            readonly property QtObject track: QtObject {
                readonly property int height: 12
                readonly property int width: 240
                readonly property color idle: Qt.alpha(Styles.colors.text, 0.1)
                readonly property color active: Styles.colors.green

                readonly property QtObject handle: QtObject {
                    readonly property color border: Styles.colors.green
                    readonly property color color: Styles.colors.green
                }
            }
        }
    }

    readonly property QtObject powermenu: QtObject {
        readonly property int width: 720
        readonly property int height: 500
    }

    readonly property QtObject controlcenter: QtObject {
        readonly property int width: 640
        readonly property int height: 500
        readonly property color background: Styles.colors.mantle
        readonly property color border: Qt.alpha(Styles.colors.subtext, 0.25)
        readonly property color text: Styles.colors.text
    }

    readonly property QtObject battery: QtObject {
        readonly property QtObject thresholds: QtObject {
            readonly property real critical: 0.2
            readonly property real warning: 0.4
        }

        readonly property QtObject pill: QtObject {
            readonly property int size: 18
            
            readonly property QtObject colors: QtObject {
                readonly property color background: Qt.alpha(Styles.colors.surface, 0.4)
                readonly property color charging: Styles.colors.peach
                readonly property color warning: Styles.colors.yellow
                readonly property color critical: Styles.colors.red

                readonly property QtObject text: QtObject {
                    readonly property color idle: Styles.colors.text
                    readonly property color active: Styles.colors.base
                }
            }
        }
    }

    readonly property QtObject bluetooth: QtObject {
        readonly property string icon: "bluetooth.svg"

        readonly property QtObject pill: QtObject {
            readonly property int maxwidth: 160
            readonly property int size: 18

            readonly property QtObject colors: QtObject {
                readonly property color background: Qt.alpha(Styles.colors.surface, 0.4)
                readonly property color text:       Styles.colors.base
                readonly property color disabled:   Styles.colors.text
                readonly property color enabled:    Styles.colors.sapphire
                readonly property color blocked:    Styles.colors.red
                readonly property color busy:       Styles.colors.yellow
            }
        }

        readonly property QtObject toolbar: QtObject {
            readonly property color text: Styles.colors.subtext

            readonly property string notscanning: "Scan for devices to update the list"

            readonly property QtObject scan: QtObject {
                readonly property QtObject background: QtObject {
                    readonly property color disabled: Qt.alpha(Styles.colors.surface, 0.2)
                    readonly property color idle: Qt.alpha(Styles.colors.surface, 0.4)
                    readonly property color active: Styles.colors.peach
                }
                readonly property QtObject text: QtObject {
                    readonly property color disabled: Qt.alpha(Styles.colors.text, 0.5)
                    readonly property color idle: Styles.colors.text
                    readonly property color active: Styles.colors.base
                }

                readonly property string icon: "reboot.svg"
                readonly property int timeout: 15000

                readonly property QtObject progressbar: QtObject {
                    readonly property color idle: Qt.alpha(Styles.colors.surface, 0.4)
                    readonly property color active: Styles.colors.green
                    readonly property int length: 30
                    readonly property bool blink: false
                }
            }
            
            readonly property QtObject toggle: QtObject {
                readonly property QtObject background: QtObject {
                    readonly property color idle: Qt.alpha(Styles.colors.surface, 0.4)
                    readonly property color active: Styles.colors.sapphire
                }

                readonly property QtObject text: QtObject {
                    readonly property color idle: Styles.colors.text
                    readonly property color active: Styles.colors.base
                }

                readonly property QtObject rotation: QtObject {
                    readonly property int idle: 0
                    readonly property int active: 270
                }

                readonly property string icon: "toggle.svg"
            }
        }

        readonly property QtObject section: QtObject {            
            readonly property color titlecolor: Styles.colors.subtext
            readonly property QtObject titles: QtObject {
                readonly property string connected: "Connected"
                readonly property string paired: "Known Devices"
                readonly property string available: "Available Devices"
                readonly property string unknown: "Unidentified Devices"
            }
        }

        readonly property QtObject device: QtObject {
            readonly property int buttonsize: 16
            readonly property color busy: Styles.colors.peach

            readonly property QtObject border: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.surface, 0.60)
                readonly property color active: Styles.colors.green
            }
            readonly property QtObject text: QtObject {
                readonly property color idle: Styles.colors.text
                readonly property color active: Styles.colors.green
            }

            readonly property QtObject connect: QtObject {
                readonly property string icon: "plug-connect.svg"
                readonly property color background: Styles.colors.green
                readonly property color text: Styles.colors.base
            }

            readonly property QtObject disconnect: QtObject {
                readonly property string icon: "plug-disconnect.svg"
                readonly property color background: Styles.colors.red
                readonly property color text: Styles.colors.base
            }

            readonly property QtObject forget: QtObject {
                readonly property string icon: "dismiss.svg"
                readonly property color background: Styles.colors.red
                readonly property color text: Styles.colors.base
            }
        }

        readonly property QtObject emptymessage: QtObject {
            readonly property color background: Qt.alpha(Styles.colors.surface, 0.2)
            readonly property color text: Styles.colors.subtext
        }

        readonly property QtObject colors: QtObject {
            readonly property color background: Qt.alpha(Styles.colors.surface, 0.4)
            readonly property QtObject text: QtObject {
                readonly property color idle: Styles.colors.text
                readonly property color active: Styles.colors.base
            }
            readonly property color disabled:   Styles.colors.subtext
            readonly property color enabled:    Styles.colors.blue
            readonly property color blocked:    Styles.colors.red
            readonly property color busy:       Styles.colors.peach
        }
    }


    readonly property QtObject network: QtObject {
        readonly property QtObject thresholds: QtObject {
            readonly property real critical: 0.2
            readonly property real warning: 0.5
        }

        readonly property QtObject pill: QtObject {
            readonly property int maxwidth: 160
            readonly property int size: 18

            readonly property QtObject colors: QtObject {
                readonly property color background: Qt.alpha(Styles.colors.surface, 0.4)
                readonly property color warning: Styles.colors.yellow
                readonly property color critical: Styles.colors.red

                readonly property QtObject text: QtObject {
                    readonly property color idle: Styles.colors.green
                    readonly property color active: Styles.colors.base
                }
            }
        }

        readonly property QtObject toolbar: QtObject {
            readonly property color text: Styles.colors.subtext

            readonly property QtObject scan: QtObject {
                readonly property QtObject background: QtObject {
                    readonly property color idle: Qt.alpha(Styles.colors.surface, 0.4)
                    readonly property color active: Styles.colors.peach
                }
                readonly property QtObject text: QtObject {
                    readonly property color idle: Styles.colors.text
                    readonly property color active: Styles.colors.base
                }

                readonly property string icon: "reboot.svg"
                readonly property int timeout: 15000

                readonly property QtObject progressbar: QtObject {
                    readonly property color idle: Qt.alpha(Styles.colors.surface, 0.4)
                    readonly property color active: Styles.colors.green
                    readonly property int length: 30
                    readonly property bool blink: false
                }
            }
        }

        readonly property QtObject section: QtObject {            
            readonly property color titlecolor: Styles.colors.subtext
        //     readonly property QtObject titles: QtObject {
        //         readonly property string connected: "Connected"
        //         readonly property string paired: "Known Devices"
        //         readonly property string available: "Available Devices"
        //         readonly property string unknown: "Unidentified Devices"
        //     }
        }

        readonly property QtObject device: QtObject {
            readonly property int buttonsize: 16
        //     readonly property color busy: Styles.colors.peach

            readonly property QtObject border: QtObject {
                readonly property color idle: Qt.alpha(Styles.colors.surface, 0.60)
                readonly property color active: Styles.colors.green
            }
            readonly property QtObject text: QtObject {
                readonly property color idle: Styles.colors.text
                readonly property color active: Styles.colors.green
            }

            readonly property QtObject connect: QtObject {
                readonly property string icon: "plug-connect.svg"
                readonly property color background: Styles.colors.green
                readonly property color text: Styles.colors.base
            }

            readonly property QtObject disconnect: QtObject {
                readonly property string icon: "plug-disconnect.svg"
                readonly property color background: Styles.colors.red
                readonly property color text: Styles.colors.base
            }
        }

        readonly property QtObject emptymessage: QtObject {
            readonly property color background: Qt.alpha(Styles.colors.surface, 0.2)
            readonly property color text: Styles.colors.subtext
        }
    }
}