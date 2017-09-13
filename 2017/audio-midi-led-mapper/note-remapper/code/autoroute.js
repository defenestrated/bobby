/*

autoroute.js

modify a route object to remap incoming midi notes

*/

// inlets + outlets
inlets = 3
outlets = 2

var debug = false;

var therouter
// var t1 = this.patcher.newdefault(10,750, "t", "b i")
var routes = []
var self

var outputs = []
var superpatcher_outs = []
var output_prepends = []

var offset = 0

var shuffle = false

init()

function logger(msg) {
  if (debug) {
    post()
    for (var m = 0; m < arguments.length; m++) {
      post(arguments[m])
    }
    post()
  }
}
function init() {
  logger("js ready")
  logger("---------------------------")
  this.patcher.apply(iterator);
}

function iterator(b) {
  var objects_to_remove = ["route", "number", "prepend", "message"]
  for (var i = 0; i < objects_to_remove.length; i++) {
    if (b.maxclass == objects_to_remove[i]) this.patcher.remove(b)
  }

  if (b.maxclass == "outlet") superpatcher_outs.push(b)

  if (b.varname == "autorouter") {
    self = b
  }

}

function addinput(note_to_route) {
  routes.push(note_to_route)
  updaterouter()
  map(shuffle)
}

function setoffset(val) {
  offset = val
  logger("output starting note:", offset)
  for (var i = 0; i < output_prepends.length; i++) {
    var pre = output_prepends[i]
    // logger(pre)
    pre.message("set", offset)
  }
}

function msg_int(int_value) {
  switch(this.inlet) {
  case 1:
    // in the right side
    setoutputs(int_value)
    break
  case 2:
    shuffle = int_value
    if (shuffle == 1) randomize()
    else organize()
    logger("shuffle:", shuffle)
    break
  }
}

function list(incoming_midi_note) {
  var parsednote = [arguments[0], arguments[1]]
  if (inlet == 0) {
    outlet(0, parsednote)
  }
}

function setoutputs(number_of_outputs) {
  var cmp = this
  for (var h = 0; h < outputs.length; h++ ) {
    this.patcher.remove(outputs[h])
    this.patcher.remove(output_prepends[h])
  }
  outputs = []

  for (var i = 0; i < number_of_outputs; i++ ) {
    outputs[i] = this.patcher.newdefault(self.rect[0]+30+(i*60), self.rect[1]+200, "number")
    var pre = cmp.patcher.newdefault(outputs[i].rect[0], outputs[i].rect[1]+30, "prepend", i+offset)
    output_prepends[i] = pre
    cmp.patcher.connect(outputs[i], 0, pre, 0)
    cmp.patcher.connect(pre, 0, superpatcher_outs[1], 0)
  }

  map(shuffle)
}

function map(shuffle) {
  var cmp = this
  var ins = routes.length,
      outs = outputs.length,
      ratio
  // post()
  logger(routes.length, outputs.length)

  var group_assign = function(position) {
    var pos = position/ratio
    var group = Math.floor(pos)
    logger("assigning", position, pos, group)
    return group
  }

  var patchem = function(more_ins_than_outs) {
    var real_outs = (shuffle) ? _.shuffle(outputs) : outputs

    var howmany = (more_ins_than_outs) ? ins : outs
    logger("times", howmany)
    _.times(howmany, function(i) {
// /      var router_outlet, number_box, which_number

      var router_outlet = (more_ins_than_outs) ? i : group_assign(i)
      var number_box = (more_ins_than_outs) ? real_outs[group_assign(i)] : real_outs[i]
      var which_number = (more_ins_than_outs) ? group_assign(i) : i

      // logger("patching", router_outlet, which_number)

      cmp.patcher.connect(therouter, router_outlet, number_box, 0)
    })
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


  // post()
}

function disconnect() {
  var cmp = this;
  _(outputs).each(function(out, ix) {
    _(routes).each(function(route, ixx) {
      cmp.patcher.disconnect(therouter, ixx, out, 0);
    })
  })
}

function randomize() {
  disconnect()
  shuffle = true
  map(shuffle)
}

function organize() {
  disconnect()
  shuffle = false
  map(shuffle)
}

function resetroutes() {
  routes = []
  updaterouter()
  map()
}

function resetall() {
  routes = []
  outputs = []
  init()
  updaterouter()
}

function update() {

}

function updaterouter() {
  this.patcher.remove(therouter)
  therouter = this.patcher.newdefault(self.rect[0]+30, self.rect[1]+30, "route", routes)
  this.patcher.connect(this.box, 0, therouter, 0)
  map(shuffle)
}
