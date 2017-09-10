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

function logger(msg) {
  post()
  post(msg)
  post()
}
function init() {
  logger("js ready")
  logger("---------------------------")
  this.patcher.apply(iterator);
}

function iterator(b) {
  var objects_to_remove = ["route", "number"]
  for (var i = 0; i < objects_to_remove.length; i++) {
    if (b.maxclass == objects_to_remove[i]) this.patcher.remove(b)
  }

  if (b.varname == "autorouter") {
    self = b
    update()
  }

}

function addinput(note_to_route) {
  routes.push(note_to_route)
  update()
  map()
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
  for (var h = 0; h < outputs.length; h++ ) {
    this.patcher.remove(outputs[h])
  }
  outputs = []

  for (var i = 0; i < number_of_outputs; i++ ) {
    outputs[i] = this.patcher.newdefault(self.rect[0]+30+(i*60), self.rect[1]+200, "number")
  }

  map()
}

function map() {
  var cmp = this
  var ins = routes.length,
      outs = outputs.length,
      ratio
  post()
  post(routes.length, outputs.length)

  var group_assign = function(position) {
    var pos = position/ratio
    var group = Math.floor(pos)
    post("assigning", position, pos, group)
    return group
  }

  function patchem(more_ins_than_outs) {
    // post("patching", ratio)
    var times = (more_ins_than_outs) ? ins : outs
    logger("times", times)
    for (var i = 0; i < times; i++) {
      var router_outlet = (more_ins_than_outs) ? i : group_assign(i)
      var number_box = (more_ins_than_outs) ? outputs[group_assign(i)] : outputs[i]
      var which_number = (more_ins_than_outs) ? group_assign(i) : i

      logger("patching", router_outlet, which_number)

      cmp.patcher.connect(therouter, router_outlet, number_box, 0)
    }
  }

  if (ins > 0 && outs > 0) {
    if (ins > outs) {
      ratio = ins / outs
      patchem(true)
    }
    else {
      ratio = outs / ins
      patchem(false)
    }
  }


  post()
}




function clear() {
  routes = []
  for (var h = 0; h < outputs.length; h++ ) {
    this.patcher.remove(outputs[h])
  }
  outputs = []
  update()
}

function update() {
  this.patcher.remove(therouter)

  therouter = this.patcher.newdefault(self.rect[0]+30, self.rect[1]+30, "route", routes)
  this.patcher.connect(this.box, 0, therouter, 0)
}
