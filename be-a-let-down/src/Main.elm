module Main exposing (main)

import Playground exposing (Computer, black, game, group, image, moveX, moveY, rectangle, rotate, scale)


main : Program () (Playground.Game {}) Playground.Msg
main =
    game view update init


init : {}
init =
    {}


update : Computer -> model -> model
update _ model =
    model


view : Computer -> model -> List Playground.Shape
view { time, screen } model =
    innerView time
        |> scale (min (screen.height / 9) (screen.width / 16))
        |> List.singleton


innerView : Playground.Time -> Playground.Shape
innerView time =
    [ image 16 9 "/background.jpg"
    , [ [ image (1060 / 1160) 1 "/be/b.png"
            |> moveX -0.4
        , image (768 / 988) 1 "/be/e.png"
            |> moveX 0.4
            |> rotate 10
        ]
            |> group
            |> moveX -3
      , [ image (2127 / 2970) 1 "/a/a.png" ]
            |> group
            |> moveX -1.45
      , [ image (444 / 1384) 1 "/let/l.png"
            |> moveX -0.65
            |> rotate 10
        , image (991 / 1151) 1 "/let/e.png"
            |> moveX 0
            |> rotate 5
        , image (744 / 1495) 1 "/let/t.png"
            |> moveX 0.8
            |> rotate -5
        ]
            |> group
            |> moveX 0
      , [ image (605 / 997) 1 "/down/d.png"
            |> moveX -1.1
            |> rotate -5
        , image (514 / 781) 1 "/down/o.png"
            |> moveX -0.4
            |> rotate -10
        , image (570 / 747) 1 "/down/w.png"
            |> moveX 0.4
            |> rotate -5
        , image (474 / 639) 1 "/down/n.png"
            |> moveX 1.2
            |> rotate -10
        ]
            |> group
            |> moveX 3
      ]
        |> group
        |> scale 1.4
    ]
        |> group
