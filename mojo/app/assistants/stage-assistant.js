function StageAssistant() {
    /* this is the creator function for your stage assistant object */

    this.aboutMessage =
        "<div style=\"float: right\"><img src=\"images/fj-logo.png\"></div>"
        + $L("Copyright 2011, Florian Jenn.") + " "
        + "<a href=\""
        + Mojo.Controller.appInfo.vendorurl
        + "\">www.effjot.net</a><br/>"
        + "<div style=\"clear: both\">"
        + $L("The table is a representation of the International Stratigraphical Chart 2009 at")
        + " <a href=\"http://www.stratigraphy.org/\">"
        + "www.stratigraphy.org</a>.<br/>"
        + $L("Additional details from Wikipedia and various geology texts.")
        + "</div>";


    /* Globals */

    StratChart = {};

    // app menu

    StratChart.appMenuAttr = { omitDefaultItems: true };
    StratChart.appMenuModel = {
        items: [
            { label: $L("Preferences"), command: 'do-prefs' },
            { label: $L("About"),       command: 'do-about' }
        ]
    };

    StratChart.wikipediaBase = "en.wikipedia.org/wiki";

    // read data for details scene

    StratChart.details = new StratigraphicData().details;

    // preferences

    this.cookie = new Mojo.Model.Cookie("StratigraphyPrefs");
    var cookiedata = this.cookie.get();
    if (cookiedata) {
        StratChart.prefs = {
            showBaseAge: cookiedata.showBaseAge,
            showGSSP:    cookiedata.showGSSP };
    } else {                    // no preferences saved yet
        StratChart.prefs = {
            showBaseAge: true,
            showGSSP:    false };
        this.cookie.put(StratChart.prefs);
    };


    // Utility functions

    String.prototype.capitalise = function() {
        return this.charAt(0).toUpperCase() + this.slice(1);
    };

    String.prototype.formatNumberLocale = function () {
        switch (Mojo.Locale.getCurrentFormatRegion()) {
        case 'de':
            return this.replace('.', ',');
            break;
        default:
            return this;
        };
    };

    String.prototype.wikipediaName = function() {
        var parts = this.split("-");
        var wikiname = parts[0].capitalise();
        for (i = 1; i < parts.length; i++) {
            wikiname = wikiname + "_" + parts[i].capitalise();
        }
        return wikiname;
    };


    StratChart.isTouchPad = function(){
        /* Detect TouchPad device; from http://www.precentral.net/developer-how-to-mojo-apps-touchpad */
        if (Mojo.Environment.DeviceInfo.modelNameAscii.indexOf("ouch") > -1)
            return true;
        if(Mojo.Environment.DeviceInfo.screenWidth == 1024){ return true; }
        if(Mojo.Environment.DeviceInfo.screenHeight == 1024){ return true; }
        return false;
    };
};


StageAssistant.prototype.setup = function() {
    /* this function is for setup tasks that have to happen when the
       stage is first created */

    this.controller.pushScene("table");
};



/* App Menu ("About" info) */

StageAssistant.prototype.handleCommand = function(event) {
    this.controller = Mojo.Controller.stageController.activeScene();
    if (event.type == Mojo.Event.command) {
        switch(event.command) {
        case 'do-about':
            this.controller.showAlertDialog(
                { onChoose: function(value) {},
                  title: $L(Mojo.Controller.appInfo.title) + " "
                         + Mojo.Controller.appInfo.version,
                  message: this.aboutMessage,
                  allowHTMLMessage: true,
                  choices: [
                      { label: $L("OK"), value: "" }
                  ]
                });
            break;

        case 'do-prefs':
            Mojo.Controller.stageController.pushScene('prefs', this);
            break;
        }
    }
};
