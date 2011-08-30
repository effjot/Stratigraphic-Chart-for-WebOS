function PrefsAssistant() {
    /* this is the creator function for your scene assistant object. It will be passed all the 
       additional parameters (after the scene name) that were passed to pushScene. The reference
       to the scene controller (this.controller) has not be established yet, so any initialization
       that needs the scene controller should be done in the setup function below. */
}

PrefsAssistant.prototype.setup = function() {
    /* this function is for setup tasks that have to happen when the scene is first created */

    /* use Mojo.View.render to render view templates and add them to the scene, if needed */

    /* setup widgets here */

    // app menu

    this.appMenuAttr = { omitDefaultItems: true };
    this.appMenuModel = {
        visible: true,
        items: [
            { label: $L('About'), command: 'do-about' }
        ]
    };
    this.controller.setupWidget(Mojo.Menu.appMenu, this.appMenuAttr, this.appMenuModel);

    // initialize settings widgets

    this.controller.setupWidget("toggleBaseAge", {},
                                { value: StratChart.prefs.showBaseAge });

    this.controller.setupWidget("toggleGSSP", {},
                                { value: StratChart.prefs.showGSSP });


    /* add event handlers to listen to events from widgets */

    this.toggleBaseAgeListener = this.toggleBaseAgeHandler.bindAsEventListener(this);
    Mojo.Event.listen(this.controller.get('toggleBaseAge'), Mojo.Event.propertyChange,
                      this.toggleBaseAgeListener);

    this.toggleGSSPListener = this.toggleGSSPHandler.bindAsEventListener(this);
    Mojo.Event.listen(this.controller.get('toggleGSSP'), Mojo.Event.propertyChange,
                      this.toggleGSSPListener);
};

PrefsAssistant.prototype.activate = function(event) {
    /* put in event handlers here that should only be in effect when
       this scene is active. For example, key handlers that are
       observing the document */
};

PrefsAssistant.prototype.deactivate = function(event) {
    /* remove any event handlers you added in activate and do any
       other cleanup that should happen before this scene is popped or
       another scene is pushed on top */

    var cookie = new Mojo.Model.Cookie("StratigraphyPrefs");
    cookie.put(StratChart.prefs);
};

PrefsAssistant.prototype.cleanup = function(event) {
    /* this function should do any cleanup needed before the scene is
       destroyed as a result of being popped off the scene stack */

    Mojo.Event.stopListening(this.controller.get('toggleBaseAge'), Mojo.Event.propertyChange,
                             this.toggleBaseAgeListener);

    Mojo.Event.stopListening(this.controller.get('toggleGSSP'), Mojo.Event.propertyChange,
                             this.toggleGSSPListener);
};


/* Handlers for buttons */

PrefsAssistant.prototype.toggleBaseAgeHandler = function(event) {
    StratChart.prefs.showBaseAge = event.value;
    StratChart.displaySettingsUpdated = true;
};

PrefsAssistant.prototype.toggleGSSPHandler = function(event) {
    StratChart.prefs.showGSSP = event.value;
    StratChart.displaySettingsUpdated = true;
};
