LP = "[lua:4rtefakt.autosave] "
CASES = {
    # Asked at tick 20: the game refuses for the room's first second, so the save lands later, in No.61; the next
    # one goes to No.62; with two slots the third wraps back to No.61. A boss's flag asks for one by itself.
    "rolling": dict(room="S_10/S_1009/S_1009", settings="Slots=2",
        drive="20:lua=as first;140:lua=as second;200:lua=as third;260:flag=220,1;330:lua=as;340:quit",
        expect=[LP + "Autosave+ loaded: No.61 to No.62", "sidecar yso_60.cleria written", LP + "autosaved to No.61 (first)",
                LP + "autosaved to No.62 (second)", LP + "autosaved to No.61 (third)", LP + "autosaved to No.62 (a boss fell)",
                LP + "want nil next 0 "]),
    # On a timer: one minute of play here (3600 ticks).
    "timer": dict(room="S_10/S_1009/S_1009", settings="Minutes=1",
        drive="3700:lua=as;3710:quit", expect=[LP + "autosaved to No.61 (1 minutes of play)", LP + "want nil next 1 "]),
    # Not while it is unsafe: with the controls taken (flag 185 = 0) the save waits, and lands when they are back.
    "waits": dict(room="S_10/S_1009/S_1009",
        drive="100:flag=185,0;110:lua=as held;200:lua=as;210:flag=185,1;260:lua=as;270:quit",
        expect=[LP + "want held next 0", LP + "want held next 0", LP + "autosaved to No.61 (held)", LP + "want nil next 1"]),
    "disabled": dict(room="S_10/S_1009/S_1009", settings="Enabled=0",
        drive="100:lua=as x;200:flag=220,1;260:quit", expect=[LP + "want nil next 0"], absent=["autosaved"]),
}
