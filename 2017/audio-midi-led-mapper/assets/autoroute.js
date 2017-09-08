/*

autoroute.js

modify a route object to remap incoming midi notes

*/

// inlets + outlets
inlets = 2
outlets = 2

var therouter
// var t1 = this.patcher.newdefault(10,750, "t", "b i")
var routes = []
var self

var outputs = []

init()

function init() {
  post("js ready")
  this.patcher.apply(iterator);
}

function iterator(b) {
  if (b.varname == "autorouter") {
    self = b
    update()
  }

}

function addinput(note_to_route) {
  routes.push(note_to_route)
  update()
}

function int(int_value) {
  if (inlet == 1) {
    // in the right side
    setoutputs(int_value)
  }
}

function list(incoming_midi_note) {
  var parsednote = [arguments[0], arguments[1]]
  if (inlet == 0) {
    outlet(0, parsednote)
  }
}

function setoutputs(number_of_outputs) {
  update()
  for (var i = 0; i < number_of_outputs; i++ ) {
    outputs[i] = this.patcher.newdefault(self.rect[0]+(i*60), self.rect[1]+80, "number")
    this.patcher.connect(therouter, i, outputs[i], 0)
  }
}

function clear() {
  routes = []
  update()
}

function update() {
  this.patcher.remove(therouter)
  for (var h = 0; h < outputs.length; h++ ) {
    this.patcher.remove(outputs[h])
  }
  therouter = this.patcher.newdefault(self.rect[0], self.rect[1]+30, "route", routes)
  this.patcher.connect(this.box, 0, therouter, 0)
}
