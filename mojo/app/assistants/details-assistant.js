function DetailsAssistant(unit) {
    /* this is the creator function for your scene assistant
       object. It will be passed all the additional parameters (after
       the scene name) that were passed to pushScene. The reference to
       the scene controller (this.controller) has not be established
       yet, so any initialization that needs the scene controller
       should be done in the setup function below. */

    this.unit = unit;
}

DetailsAssistant.prototype.setup = function() {
    /* this function is for setup tasks that have to happen when
       the scene is first created */

    /* use Mojo.View.render to render view templates and add them
       to the scene, if needed */

    /* setup widgets here */

    this.controller.setupWidget(Mojo.Menu.appMenu, StratChart.appMenuAttr,
                                StratChart.appMenuModel);

    this.controller.get("details-hdr").
        update(StratChart.details[this.unit].name);

    if (StratChart.details[this.unit].rank == "Stage/Age") {
        this.items = [
            { dt: $L("Rank"),
              dd: $L(StratChart.details[this.unit].rank) },
            { dt: $L("Begins"),
              dd: StratChart.details[this.unit].base.formatNumberLocale() },
            { dt: $L("GSSP/GSSA"),
              dd: $L(StratChart.details[this.unit].defined) }
        ];
    } else {
        this.items = [
            { dt: $L("Rank"),
              dd: $L(StratChart.details[this.unit].rank) },
            { dt: $L("Begins"),
              dd: StratChart.details[this.unit].base.formatNumberLocale() }
        ];
    }

    this.listModel = {items: this.items};

    // set up the attributes & model for the List widget

    this.controller.setupWidget('details-list',
				{itemTemplate:'details/listitem'},
				this.listModel);

    this.styleInfo = $L("Colour (RGB):") + " " +
        StratChart.details[this.unit].rgb[0] + ", "
        + StratChart.details[this.unit].rgb[1] + ", "
        + StratChart.details[this.unit].rgb[2];
    if (StratChart.details[this.unit].bright)
        this.styleInfo += " " + $L("with bright text");
    this.controller.get("style-info").update(this.styleInfo);

    this.controller.get("description-text").
        update(StratChart.details[this.unit].text);

    this.controller.setupWidget("wikipedia-button",
                                this.attributes = { },
                                this.model = {
                                    label: $L("More on Wikipedia"),
                                    buttonClass: "secondary un-capitalize",
                                    disabled: false } );

    // command menu for TouchPad (back button)

    if (StratChart.isTouchPad()) {
        var menuModel = {
            visible: true,
            items: [
                { icon: "back", command: "go-back"}
            ]
        };
        this.controller.setupWidget(Mojo.Menu.commandMenu,
                                    this.attributes = {
                                        spacerHeight: 0,
                                        menuClass: 'no-fade'
                                    },
                                    menuModel
                                   );
    }


    /* add event handlers to listen to events from widgets */

    this.controller.listen("wikipedia-button", Mojo.Event.tap,
                           this.handleUpdate.bind(this));

};

DetailsAssistant.prototype.activate = function(event) {
    /* put in event handlers here that should only be in effect when
       this scene is active. For example, key handlers that are
       observing the document */
};

DetailsAssistant.prototype.deactivate = function(event) {
    /* remove any event handlers you added in activate and do any
       other cleanup that should happen before this scene is popped or
       another scene is pushed on top */
};

DetailsAssistant.prototype.cleanup = function(event) {
    /* this function should do any cleanup needed before the scene is
       destroyed as a result of being popped off the scene stack */
};


DetailsAssistant.prototype.handleCommand = function(event) {
    if (event.type == Mojo.Event.command) {
	this.cmd = event.command;

	switch(this.cmd) {
        case 'go-back':
            this.controller.stageController.popScene();
            break;
        }
    }
};


DetailsAssistant.prototype.handleUpdate = function(event) {
    this.controller.
        serviceRequest("palm://com.palm.applicationManager", {
                           method: "open",
                           parameters:  {
                               id: 'com.palm.app.browser',
                               params: {
                                   target: "http://"
                                       + StratChart.wikipediaBase + "/"
                                       + this.unit.wikipediaName() }
                           }
                       });
};