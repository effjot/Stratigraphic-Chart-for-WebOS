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


    // Globals

    StratChart = {};

    StratChart.appMenuAttr = { omitDefaultItems: true };
    StratChart.appMenuModel = {
        items: [
            { label: $L("About"), command: 'do-about' }
        ]
    };

    StratChart.wikipediaBase = "en.wikipedia.org/wiki";

    StratChart.details = new StratigraphicData().details; // read data for details scene


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
        }
    }
};
