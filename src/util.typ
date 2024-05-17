/// Predefined color palette
#let colors = (
  orange: rgb(245, 180, 147),
  yellow: rgb(250, 225, 127),
  green: rgb(127, 200, 172),
  pink: rgb(236, 127, 178),
  purple: rgb(189, 151, 255)
)

/// Pads a string on the left with 0s to the given length
///
/// #example(`#util.lpad("0100", 8)`, mode: "markup")
///
/// - s (str): The string to pad
/// - len (int): The target length
/// -> str
#let lpad(s, len) = {
  let res = "0" * len + s
  return res.slice(-len)
}

/// Returns the anchor on the opposite side of the given one
///
/// #example(`#util.opposite-anchor("west")`, mode: "markup")
///
/// - anchor (str): The input anchor
/// -> str
#let opposite-anchor(anchor) = {
  return (
    north: "south",
    east: "west",
    south: "north",
    west: "east",

    north-west: "south-east",
    north-east: "south-west",
    south-east: "north-west",
    south-west: "north-east"
  ).at(anchor)
}

/// Returns the anchor rotated 90 degrees clockwise relative to the given one
///
/// #example(`#util.rotate-anchor("west")`, mode: "markup")
/// - anchor (str): The anchor to rotate
/// -> str
#let rotate-anchor(anchor) = {
  return (
    north: "east",
    east: "south",
    south: "west",
    west: "north",

    north-west: "north-east",
    north-east: "south-east",
    south-east: "south-west",
    south-west: "north-west"
  ).at(anchor)
}