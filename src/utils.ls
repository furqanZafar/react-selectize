{filter, map, obj-to-pairs, Str} = require \prelude-ls

# cancel-event :: Event -> Void
export cancel-event = (e) !->
    e.prevent-default!
    e.stop-propagation!

# converts {a: 1, b: 1, c: 0, d: 1} to "a b d"
# class-name-from-object :: Map String, Boolean -> String
export class-name-from-object = ->
    it 
    |> obj-to-pairs
    |> filter -> !!it.1
    |> map (.0)
    |> Str.join ' '