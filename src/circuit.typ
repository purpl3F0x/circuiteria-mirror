#import "@preview/cetz:0.3.2": canvas
#import "@preview/tidy:0.3.0"

/// Draws a block circuit diagram
///
/// This function is also available at the package root
///
/// - body (none, array, element): A code block in which draw functions have been called
/// - length (length, ratio): Optional base unit
/// -> none
#let circuit(body, length: 2em) = {
  let next-id = 0
  let elements = (:)

  for element in body {
    let internal = type(element) == dictionary and "id" in element
    let eid = if internal {element.id} else {none}
    if eid == none {
      while str(next-id) in elements {
        next-id += 1
      }
      eid = str(next-id)
      if internal {
        element.id = eid
      }
      next-id += 1
    }
    elements.insert(eid, element)
  }

  for element in elements.values() {
    if type(element) == dictionary and "pre-process" in element {
      elements = (element.pre-process)(elements, element)
    }
  }

  canvas(length: length, {
    for element in elements.values() {
      if type(element) == dictionary and "draw" in element {
        (element.draw)(element)
      } else {
        (element,)
      }
    }
  })
}