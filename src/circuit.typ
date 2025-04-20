#import "/src/cetz.typ": canvas
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
  let ids = ()
  for e in body {
    if type(e) == dictionary and "id" in e {
      ids.push(e.id)
    }
  }

  for element in body {
    let internal = type(element) == dictionary and "id" in element
    let eid = if internal {element.id} else {auto}
    if eid == auto {
      while str(next-id) in ids {
        next-id += 1
      }
      eid = str(next-id)
      ids.push(eid)
      if internal {
        element.id = eid
      }
      next-id += 1
    }
    if eid in elements {
      panic("An element with the id '" + eid + "' already exists. Please use a different id")
    }
    elements.insert(eid, element)
  }

  for element in elements.values() {
    if type(element) == dictionary and "pre-process" in element {
      elements = (element.pre-process)(elements, element)
      assert(
        type(elements) == dictionary,
        message: "The `pre-process` method of element '" + element.id + "' did not return the elements dictionary"
      )
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