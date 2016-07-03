require! <[fs]>
traverse = (node, depth, index, store = {projects: []}) ->
  if Array.isArray(node) =>
    for i from 0 til node.length => traverse(node[i], depth + 1, (if !i => index + 1 else 0), store)
  else 
    if index >= 3 =>
      store.area = node
      delete store.category
      delete store.parent
    else if index == 2 =>
      store.category = node
      delete store.parent
    else if index == 1 =>
      store.parent = node
    else => 
      ret = /^- \[([^\]]+)\]\(([^)]+)\) - (.+)/.exec node
      if !ret => return
      object = do
        name: ret.1
        repository: ret.2
        description: ret.3
        area: store.area
      if store.category and !store.parent => object.partOf = store.category
      else object <<< {category: store.category, partOf: store.parent}
      <[name href description area category parent]>.map -> if !(object[it]?) => delete object[it]
      store.projects.push object

breakdown = (text, breaker) ->
  text.trim!
    .split breaker
    .filter(->it)
    .map(->it.trim!)

context = fs.read-file-sync \readme.md .toString!
  .trim!
  .split "[comment]: <> (LIST-BEGIN)" .1
  .split "[comment]: <> (LIST-END)" .0

sections = breakdown context, /^## |\n## / .map ->
  subsection = breakdown it, /\n### / .map ->
    project = breakdown it, /\n#### / .map ->
      it.split \\n .filter(->it)

store = {projects: []}
traverse sections, 0, 0, store
fs.write-file-sync \awesome-g0v.json, JSON.stringify(store.projects)
