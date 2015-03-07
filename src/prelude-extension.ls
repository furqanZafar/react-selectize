{filter, find, map, partition, reverse, sort-by} = require \prelude-ls

clamp = (n, min, max) -> Math.max min, (Math.min max, n)

find-all = (text, search, offset = 0, indices = []) ->
    index = text .substr offset .index-of search
    return indices if index == -1
    find-all do
        text
        search
        offset + index + search.length
        indices ++ [offset + index]

partition-string = (text, search) ->
    return [[0, text.length]] if search.length == 0
    [first, ..., x]:indices = find-all text, search
    return [] if indices.length == 0
    last = x + search.length
    high = indices
        |> map -> [it, it + search.length, true]
    low = [0 til high.length - 1]
        |> map (i) ->
            [high[i].1, high[i + 1].0, false]
    (if first == 0 then [] else [[0, first, false]]) ++
    ((high ++ low) |> sort-by (.0)) ++
    (if last == text.length then [] else [[last, text.length, false]])

remove = (f, c) --> c |> partition f |> (.1)

exports = module.exports = {clamp, find-all, partition-string, remove}