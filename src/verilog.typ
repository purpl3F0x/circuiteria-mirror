#import "/src/cetz.typ": draw
#import "elements/block.typ": block as block-element
#import "util.typ"
#import "wire.typ"

// ---------------------------------------------------------------------------
// Low level helpers
// ---------------------------------------------------------------------------

#let _ident = "(?:\\\\\\S+|[A-Za-z_][A-Za-z0-9_$]*)"
#let _net-kw = "(?:var|wire|reg|logic|bit|tri|tri0|tri1|triand|trior|wand|wor|uwire|supply0|supply1|signed|unsigned)"

#let _strip-comments(src) = {
  let s = src.replace(regex("(?s)/\\*.*?\\*/"), " ")
  s = s.replace(regex("//[^\n]*"), " ")
  return s
}

// Finds the index of the closing bracket matching the opening one at `start`
#let _find-close(chars, start) = {
  let pairs = ("(": ")", "[": "]", "{": "}")
  let open = chars.at(start)
  let close = pairs.at(open)
  let depth = 0
  let i = start
  while i < chars.len() {
    let c = chars.at(i)
    if c == open {
      depth += 1
    } else if c == close {
      depth -= 1
      if depth == 0 { return i }
    }
    i += 1
  }
  return none
}

// Splits a text on commas that are not nested inside brackets
#let _split-commas(text) = {
  let items = ()
  let depth = 0
  let cur = ()
  for c in text.clusters() {
    if c in ("(", "[", "{") {
      depth += 1
    } else if c in (")", "]", "}") {
      depth -= 1
    }
    if c == "," and depth <= 0 {
      items.push(cur.join())
      cur = ()
    } else {
      cur.push(c)
    }
  }
  if cur.join().trim() != "" { items.push(cur.join()) }
  return items.filter(it => it.trim() != "")
}

// Evaluates a very simple integer expression (`4`, `32-1`, `8+2`)
#let _eval-int(expr) = {
  if expr == none { return none }
  let e = expr.replace(regex("\\s+"), "")
  if e.match(regex("^[0-9]+$")) != none { return int(e) }
  let m = e.match(regex("^([0-9]+)([+*-])([0-9]+)$"))
  if m == none { return none }
  let a = int(m.captures.at(0))
  let b = int(m.captures.at(2))
  let op = m.captures.at(1)
  if op == "+" { return a + b }
  if op == "-" { return a - b }
  return a * b
}

// Extracts the first packed range (`[7:0]`) of a dimension list
#let _first-range(dims) = {
  if dims == none { return none }
  let m = dims.match(regex("\\[([^\\]]*)\\]"))
  if m == none { return none }
  return m.captures.at(0).trim()
}

// Computes the width of a range text (`7:0` -> 8), `none` if not constant
#let _range-width(range) = {
  if range == none { return 1 }
  let m = range.match(regex("^([^:]+):([^:]+)$"))
  if m == none { return none }
  let hi = _eval-int(m.captures.at(0))
  let lo = _eval-int(m.captures.at(1))
  if hi == none or lo == none { return none }
  return calc.abs(hi - lo) + 1
}

#let _make-port(name, dir, dims) = {
  let range = _first-range(dims)
  return (
    name: name,
    dir: dir,
    range: range,
    width: _range-width(range)
  )
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

#let _parse-ansi-ports(portlist) = {
  let ports = ()
  let last-dir = "input"
  let last-dims = none
  for item in _split-commas(portlist) {
    let m = item.match(regex(
      "^\\s*(?:(input|output|inout)\\s+)?(?:" + _net-kw + "\\s+)*" +
      "((?:\\[[^\\]]*\\]\\s*)*)(" + _ident + ")"
    ))
    if m == none { continue }
    let (dir, dims, name) = (m.captures.at(0), m.captures.at(1), m.captures.at(2))
    if dir != none {
      last-dir = dir
      last-dims = dims
    } else if dims == none or dims.trim() == "" {
      dims = last-dims
    }
    ports.push(_make-port(name, last-dir, dims))
  }
  return ports
}

#let _parse-body-ports(portlist, body) = {
  let decls = (:)
  for m in body.matches(regex(
    "(?s)\\b(input|output|inout)\\b((?:\\s+" + _net-kw + ")*)\\s*" +
    "((?:\\[[^\\]]*\\]\\s*)*)([^;]*);"
  )) {
    let dir = m.captures.at(0)
    let dims = m.captures.at(2)
    for n in _split-commas(m.captures.at(3)) {
      let nm = n.match(regex("^\\s*(" + _ident + ")\\s*$"))
      if nm == none { continue }
      decls.insert(nm.captures.at(0), _make-port(nm.captures.at(0), dir, dims))
    }
  }

  let ports = ()
  for item in _split-commas(portlist) {
    let m = item.match(regex("(" + _ident + ")\\s*$"))
    if m == none { continue }
    let name = m.captures.at(0)
    if name in decls { ports.push(decls.at(name)) }
  }
  // Declared but not listed (or unparsable port list): append the rest
  for (name, port) in decls {
    if ports.find(it => it.name == name) == none { ports.push(port) }
  }
  return ports
}

#let _parse-module(chunk) = {
  let m = chunk.match(regex("^\\s*module\\s+(" + _ident + ")"))
  if m == none { return none }
  let name = m.captures.at(0)
  let chars = chunk.slice(m.end).clusters()

  let i = 0
  while i < chars.len() and chars.at(i).trim() == "" { i += 1 }

  let params = ()
  if i < chars.len() and chars.at(i) == "#" {
    while i < chars.len() and chars.at(i) != "(" { i += 1 }
    let close = _find-close(chars, i)
    if close == none { return none }
    for p in _split-commas(chars.slice(i + 1, close).join()) {
      let pm = p.match(regex("(" + _ident + ")\\s*=\\s*([^,]+)$"))
      if pm != none {
        params.push((name: pm.captures.at(0), value: pm.captures.at(1).trim()))
      }
    }
    i = close + 1
  }

  while i < chars.len() and chars.at(i) != "(" and chars.at(i) != ";" { i += 1 }

  let portlist = ""
  if i < chars.len() and chars.at(i) == "(" {
    let close = _find-close(chars, i)
    if close == none { return none }
    portlist = chars.slice(i + 1, close).join()
    i = close + 1
  }
  let body = if i < chars.len() { chars.slice(i).join() } else { "" }

  let ports = if portlist.match(regex("\\b(input|output|inout)\\b")) != none {
    _parse-ansi-ports(portlist)
  } else {
    _parse-body-ports(portlist, body)
  }

  return (name: name, params: params, ports: ports)
}

/// Parses Verilog/SystemVerilog source code and returns the declared modules.
///
/// Both ANSI (`module m(input clk, ...)`) and non-ANSI
/// (`module m(clk, ...); input clk;`) port styles are supported.
///
/// ```typ
/// #let modules = verilog.parse(read("my_module.v"))
/// ```
///
/// - source (str): The Verilog source code, typically obtained with `read()`
/// -> array
#let parse(source) = {
  let src = _strip-comments(source)
  let modules = ()
  for m in src.matches(regex("\\bmodule\\b")) {
    let rest = src.slice(m.start)
    let pos = rest.slice(6).position(regex("\\bendmodule\\b"))
    let chunk = if pos == none { rest } else { rest.slice(0, 6 + pos) }
    let parsed = _parse-module(chunk)
    if parsed != none { modules.push(parsed) }
  }
  return modules
}

/// Returns a single module from Verilog source code.
///
/// - source (str, array, dictionary): Verilog source code, an array of parsed modules or an already parsed module
/// - name (none, str): Name of the wanted module. If `none`, the first module is returned
/// -> dictionary
#let get-module(source, name: none) = {
  let modules = if type(source) == str {
    parse(source)
  } else if type(source) == dictionary {
    (source,)
  } else {
    source
  }
  if modules.len() == 0 { panic("No Verilog module found") }
  if name == none { return modules.first() }
  let found = modules.find(it => it.name == name)
  if found == none { panic("Could not find Verilog module " + name) }
  return found
}

// ---------------------------------------------------------------------------
// Bus / clock / reset inference
// ---------------------------------------------------------------------------

#let axis-suffixes = (
  "tvalid", "tready", "tdata", "tlast", "tkeep", "tstrb",
  "tuser", "tid", "tdest", "twakeup"
)

#let axi-suffixes = (
  "awid", "awaddr", "awlen", "awsize", "awburst", "awlock", "awcache",
  "awprot", "awqos", "awregion", "awuser", "awvalid", "awready",
  "wid", "wdata", "wstrb", "wlast", "wuser", "wvalid", "wready",
  "bid", "bresp", "buser", "bvalid", "bready",
  "arid", "araddr", "arlen", "arsize", "arburst", "arlock", "arcache",
  "arprot", "arqos", "arregion", "aruser", "arvalid", "arready",
  "rid", "rdata", "rresp", "rlast", "ruser", "rvalid", "rready"
)

// Signals that only exist on full AXI4 (used to tell AXI4 from AXI4-Lite)
#let axi-full-only = (
  "awid", "awlen", "awsize", "awburst", "awlock", "awcache", "awqos",
  "awregion", "wid", "wlast", "bid",
  "arid", "arlen", "arsize", "arburst", "arlock", "arcache", "arqos",
  "arregion", "rid", "rlast"
)

#let _clock-re = regex("(?i)(^|[^a-z0-9])(a?clk|clock)([0-9]*)($|[^a-z0-9])")
#let _reset-re = regex("(?i)(^|[^a-z0-9])(a?rst|a?reset)(_?n)?([0-9]*)($|[^a-z0-9])")

#let _is-clock(name) = name.match(_clock-re) != none
#let _is-reset(name) = name.match(_reset-re) != none
#let _is-active-low(name) = name.match(regex("(?i)(_n|_b|_l|resetn|rstn)$")) != none

// Splits a signal name into (prefix, suffix) using the given suffix table
#let _match-suffix(name, suffixes) = {
  let lower = lower(name)
  let best = none
  for s in suffixes {
    if not lower.ends-with(s) { continue }
    if lower.len() == s.len() {
      if best == none or s.len() > best.len() { best = s }
      continue
    }
    let sep = lower.at(lower.len() - s.len() - 1)
    if sep != "_" { continue }
    if best == none or s.len() > best.len() { best = s }
  }
  if best == none { return none }
  let prefix = name.slice(0, name.len() - best.len())
  return (prefix: prefix.trim("_", at: end), suffix: best)
}

#let _group-signals(ports) = {
  let groups = (:)
  let rest = ()
  for port in ports {
    let kind = none
    let m = _match-suffix(port.name, axis-suffixes)
    if m != none {
      kind = "axi-stream"
    } else {
      m = _match-suffix(port.name, axi-suffixes)
      if m != none { kind = "axi" }
    }
    if m == none {
      rest.push(port)
      continue
    }
    let key = kind + "|" + lower(m.prefix)
    let group = groups.at(key, default: (
      kind: kind,
      prefix: m.prefix,
      signals: (:)
    ))
    group.signals.insert(m.suffix, port)
    groups.insert(key, group)
  }
  return (groups: groups, rest: rest)
}

#let _bus-width(group, ..names) = {
  for n in names.pos() {
    if n in group.signals {
      return group.signals.at(n).width
    }
  }
  return none
}

#let _finalize-bus(group) = {
  let sig = group.signals
  let kind = group.kind

  if kind == "axi-stream" {
    if "tvalid" not in sig and not ("tdata" in sig and "tready" in sig) {
      return none
    }
  } else {
    if sig.len() < 4 { return none }
    if "awvalid" not in sig and "arvalid" not in sig { return none }
    let lite = sig.keys().find(it => it in axi-full-only) == none
    if lite or lower(group.prefix).contains(regex("axil|lite")) {
      kind = "axi-lite"
    }
  }

  let ref = if kind == "axi-stream" {
    sig.at("tvalid", default: sig.at("tdata", default: none))
  } else {
    sig.at("awvalid", default: sig.at("arvalid", default: none))
  }
  let role = if ref != none and ref.dir == "output" { "master" } else { "slave" }

  return (
    kind: kind,
    prefix: group.prefix,
    role: role,
    dir: if role == "master" { "output" } else { "input" },
    data-width: _bus-width(group, "tdata", "wdata", "rdata"),
    addr-width: _bus-width(group, "awaddr", "araddr"),
    signals: sig,
    ports: sig.values()
  )
}

/// Analyses the ports of a module and infers AXI4, AXI4-Lite and AXI4-Stream
/// buses as well as clock and reset signals.
///
/// The returned dictionary contains:
/// - `buses`: array of inferred buses. Each bus has the fields `kind`
///   (`"axi"`, `"axi-lite"` or `"axi-stream"`), `prefix`, `role`
///   (`"master"` or `"slave"`), `dir`, `data-width`, `addr-width` and `signals`
/// - `clocks`: array of clock ports
/// - `resets`: array of reset ports (with an additional `active-low` field)
/// - `signals`: array of the remaining ports
///
/// - module (str, array, dictionary): Verilog source code or a parsed module
/// - name (none, str): Name of the wanted module (when several are present)
/// -> dictionary
#let analyze(module, name: none) = {
  let module = get-module(module, name: name)

  let clocks = ()
  let resets = ()
  let others = ()
  for port in module.ports {
    if _is-clock(port.name) {
      clocks.push(port)
    } else if _is-reset(port.name) {
      resets.push(port + (active-low: _is-active-low(port.name)))
    } else {
      others.push(port)
    }
  }

  let (groups, rest) = _group-signals(others)
  let buses = ()
  let signals = rest
  for (_, group) in groups {
    let bus = _finalize-bus(group)
    if bus == none {
      signals += group.signals.values()
    } else {
      buses.push(bus)
    }
  }
  buses = buses.sorted(key: it => it.prefix)

  return (
    name: module.name,
    params: module.params,
    buses: buses,
    clocks: clocks,
    resets: resets,
    signals: signals,
    ports: module.ports
  )
}

// ---------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------

#let bus-kind-names = (
  "axi": "AXI4",
  "axi-lite": "AXI4-Lite",
  "axi-stream": "AXI4-Stream"
)

#let _bus-label(bus, show-widths: true, show-info: false) = {
  let title = if bus.prefix != "" { bus.prefix } else { bus-kind-names.at(bus.kind) }
  let info = ()
  if show-info {
    if bus.prefix != "" { info.push(bus-kind-names.at(bus.kind)) }
    if show-widths and bus.data-width != none {
      info.push(str(bus.data-width) + "b")
    }
  }
  if info.len() == 0 {
    return (label: title, len: title.len())
  }
  let sub = info.join(" ")
  return (
    label: box(align(left)[#title \ #text(size: 0.7em, sub)]),
    len: calc.max(title.len(), int(sub.len() * 0.7))
  )
}

#let _signal-label(port, show-widths: true) = {
  let label = if show-widths and port.range != none {
    port.name + "[" + port.range + "]"
  } else {
    port.name
  }
  return (label: label, len: label.len())
}

// Approximate width (in canvas units) of a label of `len` characters
#let _text-width(len) = 0.28 * len

/// Builds the ports dictionary of a Verilog module, ready to be given to
/// #doc-ref("element.elmt").
///
/// Inputs (and slave buses) are placed on the west side, outputs (and master
/// buses) on the east side, clocks and resets on top of the west side.
///
/// - module (str, array, dictionary): Verilog source code or a parsed module
/// - name (none, str): Name of the wanted module (when several are present)
/// - show-widths (bool): Whether to append the signal widths to their names
/// - show-bus-info (bool): Whether to display the bus kind and data width below the bus name
/// - clock-side (str): Side on which clock ports are placed
/// - reset-side (str): Side on which reset ports are placed
/// -> dictionary
#let module-ports(
  module,
  name: none,
  show-widths: true,
  show-bus-info: false,
  clock-side: "west",
  reset-side: "west"
) = {
  let info = if type(module) == dictionary and "buses" in module {
    module
  } else {
    analyze(module, name: name)
  }

  let ports = (north: (), east: (), south: (), west: ())

  for bus in info.buses {
    let side = if bus.dir == "output" { "east" } else { "west" }
    let label = _bus-label(bus, show-widths: show-widths, show-info: show-bus-info)
    ports.at(side).push((
      id: bus.prefix,
      name: label.label,
      label-len: label.len,
      bus: true,
      kind: bus.kind,
      multiline: type(label.label) != str
    ))
  }

  for port in info.clocks {
    let vertical = clock-side in ("north", "south")
    ports.at(clock-side).push((
      id: port.name,
      // indented so that the label does not collide with the clock triangle
      name: if vertical { "" } else { box(inset: (left: 0.7em), port.name) },
      label-len: port.name.len() + 2,
      clock: true,
      small: true
    ))
  }

  for port in info.resets {
    ports.at(reset-side).push((
      id: port.name,
      name: port.name,
      label-len: port.name.len(),
      invert: port.active-low,
      vertical: reset-side in ("north", "south")
    ))
  }

  for port in info.signals {
    let side = if port.dir == "output" { "east" } else { "west" }
    let label = _signal-label(port, show-widths: show-widths)
    ports.at(side).push((
      id: port.name,
      name: label.label,
      label-len: label.len,
      invert: _is-active-low(port.name),
      bus: port.width == none or port.width > 1
    ))
  }

  return ports
}

/// Draws a block from a Verilog module description.
///
/// AXI4, AXI4-Lite and AXI4-Stream signals are grouped into single bus ports,
/// and clock/reset signals are automatically detected and grouped together.
///
/// ```typ
/// #circuiteria.circuit({
///   circuiteria.verilog.block(read("axi_dma.v"), x: 0, y: 0)
/// })
/// ```
///
/// The port ids are the signal names (or the bus prefixes), so wires can be
/// attached with `"<id>-port-<signal>"`.
///
/// - module (str, array, dictionary): Verilog source code or a parsed module
/// - module-name (none, str): Name of the wanted module (when several are present)
/// - x (number, dictionary): The x position (bottom-left corner)
/// - y (number, dictionary): The y position (bottom-left corner)
/// - w (auto, number): Width of the block. Computed from the port names if `auto`
/// - h (auto, number): Height of the block. Computed from the port count if `auto`
/// - id (auto, str): The block id. Defaults to the module name
/// - name (auto, none, str, content): Name displayed in the block. Defaults to the module name
/// - name-anchor (str): Anchor for the displayed name
/// - show-widths (bool): Whether to append the signal widths to their names
/// - show-bus-info (bool): Whether to display the bus kind and data width below the bus name
/// - stubs (bool): Whether to draw an unnamed wire stub on every port
/// - stub-length (number, length): Length of the automatic stubs
/// - bus-markers (bool): Whether to draw the bus stubs as double lines
/// - clock-side (str): Side on which clock ports are placed
/// - reset-side (str): Side on which reset ports are placed
/// - fill (none, color): Fill color
/// - stroke (stroke): Border stroke
/// - radius (number, length, ratio, dictionary): The corner radius of the block
/// - ports-margins (dictionary): Dictionary of ports margins
/// - debug (dictionary): Dictionary of debug options
#let block(
  module,
  module-name: none,
  x: 0,
  y: 0,
  w: auto,
  h: auto,
  id: auto,
  name: auto,
  name-anchor: "south",
  show-widths: true,
  show-bus-info: false,
  stubs: true,
  stub-length: 1em,
  bus-markers: true,
  clock-side: "west",
  reset-side: "west",
  fill: none,
  stroke: black + 1pt,
  radius: 0.5em,
  ports-margins: (:),
  debug: (ports: false)
) = {
  let info = if type(module) == dictionary and "buses" in module {
    module
  } else {
    analyze(module, name: module-name)
  }
  let ports = module-ports(
    info,
    show-widths: show-widths,
    show-bus-info: show-bus-info,
    clock-side: clock-side,
    reset-side: reset-side
  )

  let id = if id == auto { info.name } else { id }
  let name = if name == auto { raw(info.name) } else { name }

  let max-len(side) = {
    let lens = ports.at(side).map(it => it.at("label-len", default: 8))
    if lens.len() == 0 { 0 } else { calc.max(..lens) }
  }
  let sum-len(side) = {
    ports.at(side).fold(0, (acc, it) => acc + it.at("label-len", default: 8))
  }
  // Two-line (bus) labels need more vertical room
  let rows-weight(side) = {
    ports.at(side).fold(0, (acc, it) => acc + if it.at("multiline", default: false) { 1.6 } else { 1 })
  }

  let vert-count = calc.max(ports.north.len(), ports.south.len(), 0)

  let margins = ports-margins
  for side in ("west", "east") {
    if side not in margins { margins.insert(side, (8%, 14%)) }
  }

  let h = if h != auto { h } else {
    let rows = calc.max(rows-weight("west"), rows-weight("east"), 1)
    calc.max(1.8, rows * 1.05 / 0.72, if vert-count > 0 { 2.2 } else { 0 })
  }
  let w = if w != auto { w } else {
    let inner = _text-width(max-len("west") + max-len("east")) + 0.8
    let title = _text-width(info.name.len() * 1.2) + 0.8
    let vert-len = calc.max(sum-len("north"), sum-len("south"))
    let vert = _text-width(vert-len) + 0.5 * vert-count + 0.4
    calc.max(2.5, inner, title, vert)
  }

  block-element(
    x: x,
    y: y,
    w: w,
    h: h,
    id: id,
    name: name,
    name-anchor: name-anchor,
    ports: ports,
    ports-margins: margins,
    fill: fill,
    stroke: stroke,
    radius: radius,
    debug: debug
  )

  if stubs {
    // active-low ports carry a bubble, so their stub starts past it
    let bubble = (north: (0, 0.2), east: (0.2, 0), south: (0, -0.2), west: (-0.2, 0))
    let ends = (north: (0, stub-length), east: (stub-length, 0), south: (0, -stub-length), west: (-stub-length, 0))
    let gap = 0.1
    for (side, side-ports) in ports {
      for port in side-ports {
        let anchor = id + "-port-" + port.id
        let is-bus = port.at("bus", default: false)
        if bus-markers and "kind" in port {
          let perp = if side in ("east", "west") { (0, gap) } else { (gap, 0) }
          // starts past the block border so the fill does not cover it
          let o = 0.02
          let edge = (north: (0, o), east: (o, 0), south: (0, -o), west: (-o, 0)).at(side)
          draw.rect(
            (rel: (edge.at(0) - perp.at(0), edge.at(1) - perp.at(1)), to: anchor),
            (rel: ends.at(side), to: (rel: perp, to: anchor)),
            fill: luma(80%),
            stroke: none
          )
          for k in (1, 0, -1) {
            let start = (rel: (perp.at(0) * k, perp.at(1) * k), to: anchor)
            draw.line(start, (rel: ends.at(side), to: start), stroke: wire.signal-width)
          }
        } else if port.at("invert", default: false) {
          draw.line(
            (rel: bubble.at(side), to: anchor),
            (rel: ends.at(side), to: anchor),
            stroke: if is-bus { wire.bus-width } else { wire.signal-width }
          )
        } else {
          wire.stub(anchor, side, length: stub-length, bus: is-bus)
        }
      }
    }
  }
}
