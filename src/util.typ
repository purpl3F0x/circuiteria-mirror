#let colors = (
  orange: rgb(245, 180, 147),
  yellow: rgb(250, 225, 127),
  green: rgb(127, 200, 172),
  pink: rgb(236, 127, 178),
  purple: rgb(189, 151, 255)
)

#let lpad(s, len) = {
  let res = "0" * len + s
  return res.slice(-len)
}

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