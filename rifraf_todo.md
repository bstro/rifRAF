# RifRAF TODO
# updated 5-30-13

* -Add support for relative movement.-
* Color transitions.
* Gradient transitions
* Background position (x-pos, y-pos)
* Clone another actor's configuration
* Add a property or method to delete an actor for a specific element. For example, say I instantiated all the .boxes, but I want the last .box to do something different; I need a way to clear the inheritance from all the .boxes for the last .box without having to refactor and re-apply selectors.
* Does this need CommonJS or AMD support?
* Make an option for no_paints that relies on the mouse wheel delta if it exists. Need to understand more about how reliable/unreliable this would be.
* Read into WebGL; would it be feasible to add support?
* Make actor.parseOptions() recursive.
* Figure out way to recognize and animate based on existing styles; especially in the case of multiple transform properties, the user might wish to have a static scaled element with a animated rotation.
* Have a "horizontal" scroller mode that intercepts vertical scrolling events; variables should be abstracted out to something like "dimensionSize" or something less silly.
* Allow a callback to be specified when rifraf is instantiated like so:
# 	$(element).rifraf ->
# 		property: 'margin-top'
# 		movement: -> … # ex., could specify sinusoidal movement.