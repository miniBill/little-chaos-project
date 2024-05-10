module Main exposing (Flags, Model, Msg, main)

import Angle exposing (Angle)
import Array
import Browser
import Browser.Dom
import Browser.Events
import Duration exposing (Duration)
import Html exposing (Html)
import Html.Attributes
import List.Extra
import Math.Matrix4 as Matrix4 exposing (Mat4)
import Math.Vector3 exposing (Vec3, vec3)
import Pixels exposing (Pixels)
import Quantity exposing (Quantity)
import Task
import TriangularMesh exposing (TriangularMesh)
import WebGL exposing (Entity, Mesh, Shader)


type alias Flags =
    {}


type alias Model =
    { time : Duration
    , width : Quantity Int Pixels
    , height : Quantity Int Pixels
    }


quad : number -> number -> number -> number -> List ( number, number, number )
quad pa pb pc pd =
    [ ( pa, pb, pd ), ( pd, pb, pc ) ]


type alias Uniforms =
    { model : Mat4
    , perspective : Mat4
    }


type alias Attributes =
    { position : Vec3 }


type alias Varyings =
    {}


i : Mesh Attributes
i =
    extrude
        [ ( 0, 0 )
        , ( 3, 0 )
        , ( 3, 1 )
        , ( 2, 1 )
        , ( 2, 4 )
        , ( 3, 4 )
        , ( 3, 5 )
        , ( 0, 5 )
        , ( 0, 4 )
        , ( 1, 4 )
        , ( 1, 1 )
        , ( 0, 1 )
        ]
        [ quad 0 11 2 1
        , quad 10 9 4 3
        , quad 8 7 6 5
        ]


s : Mesh Attributes
s =
    extrude
        [ ( 0, 0 )
        , ( 3, 0 )
        , ( 3, 1 )
        , ( 1, 1 )
        , ( 1, 2 )
        , ( 2, 2 )
        , ( 3, 2 )
        , ( 3, 4 )
        , ( 3, 5 )
        , ( 0, 5 )
        , ( 0, 4 )
        , ( 2, 4 )
        , ( 2, 3 )
        , ( 1, 3 )
        , ( 0, 3 )
        , ( 0, 1 )
        ]
        [ quad 0 15 2 1
        , quad 15 14 13 3
        , quad 4 13 12 5
        , quad 5 11 7 6
        , quad 10 9 8 7
        ]


n : Mesh Attributes
n =
    extrude
        [ ( 0, 0 )
        , ( 1, 0 )
        , ( 1, 1 )
        , ( 2, 2 )
        , ( 2, 0 )
        , ( 3, 0 )
        , ( 3, 5 )
        , ( 2, 5 )
        , ( 2, 4 )
        , ( 1, 3 )
        , ( 1, 5 )
        , ( 0, 5 )
        ]
        [ quad 0 11 10 1
        , quad 2 9 8 3
        , quad 4 7 6 5
        ]


e : Mesh Attributes
e =
    extrude
        [ ( 0, 0 )
        , ( 3, 0 )
        , ( 3, 1 )
        , ( 1, 1 )
        , ( 1, 2 )
        , ( 3, 2 )
        , ( 3, 3 )
        , ( 1, 3 )
        , ( 1, 4 )
        , ( 3, 4 )
        , ( 3, 5 )
        , ( 0, 5 )
        , ( 0, 4 )
        , ( 0, 3 )
        , ( 0, 2 )
        , ( 0, 1 )
        ]
        [ quad 0 15 2 1
        , quad 15 14 4 3
        , quad 14 13 6 5
        , quad 13 12 8 7
        , quad 12 11 10 9
        ]


v : Mesh Attributes
v =
    extrude
        [ ( 0, 0 )
        , ( 1, 0 )
        , ( 1, 4 )
        , ( 2, 4 )
        , ( 2, 0 )
        , ( 3, 0 )
        , ( 3, 4 )
        , ( 2, 5 )
        , ( 1, 5 )
        , ( 0, 4 )
        ]
        [ quad 0 9 2 1
        , [ ( 9, 8, 2 ) ]
        , quad 2 8 7 3
        , [ ( 3, 7, 6 ) ]
        , quad 4 3 6 5
        ]


r : Mesh Attributes
r =
    extrude
        [ ( 0, 0 )
        , ( 2, 0 )
        , ( 3, 1 )
        , ( 3, 2 )
        , ( 2, 3 )
        , ( 3, 4 )
        , ( 3, 5 )
        , ( 2, 5 )
        , ( 2, 4 )
        , ( 1, 3 )
        , ( 1, 5 )
        , ( 0, 5 )
        , ( 0, 1 )
        , ( 0, 0 )
        , ( 1, 1 )
        , ( 1, 2 )
        , ( 2, 2 )
        , ( 2, 1 )
        ]
        [ quad 0 12 17 1
        , quad 1 17 3 2
        , [ ( 17, 16, 3 ) ]
        , quad 12 11 10 14
        , quad 15 9 4 3
        , quad 9 8 5 4
        , quad 8 7 6 5
        ]


a : Mesh Attributes
a =
    extrude
        [ ( 0, 0 )
        , ( 1, 0 )
        , ( 2, 0 )
        , ( 3, 0 )
        , ( 3, 5 )
        , ( 2, 5 )
        , ( 2, 4 )
        , ( 1, 4 )
        , ( 1, 5 )
        , ( 0, 5 )
        , ( 0, 0 )
        , ( 1, 1 )
        , ( 1, 3 )
        , ( 2, 3 )
        , ( 2, 1 )
        ]
        [ quad 0 9 8 1
        , quad 1 11 14 2
        , quad 12 7 6 13
        , quad 2 5 4 3
        ]


y : Mesh Attributes
y =
    extrude
        [ ( 0, 0 )
        , ( 1, 0 )
        , ( 1, 2 )
        , ( 2, 2 )
        , ( 2, 0 )
        , ( 3, 0 )
        , ( 3, 3 )
        , ( 2, 3 )
        , ( 2, 5 )
        , ( 1, 5 )
        , ( 1, 3 )
        , ( 0, 3 )
        ]
        [ quad 0 11 10 1
        , quad 2 9 8 3
        , quad 4 7 6 5
        ]


extrude : List ( Float, Float ) -> List (List ( Int, Int, Int )) -> Mesh Attributes
extrude points indexes =
    let
        step : comparable -> ( comparable, comparable ) -> ( comparable, comparable )
        step val (( mn, mx ) as m) =
            if val < mn then
                ( val, mx )

            else if val > mx then
                ( mn, val )

            else
                m

        ( centerx, centery ) =
            case points of
                [] ->
                    ( 0, 0 )

                ( headx, heady ) :: tail ->
                    let
                        ( ( minx, maxx ), ( miny, maxy ) ) =
                            List.foldl
                                (\( x, y_ ) ( mx, my ) ->
                                    ( step x mx, step y_ my )
                                )
                                ( ( headx, headx ), ( heady, heady ) )
                                tail
                    in
                    ( (minx + maxx) / 2, (miny + maxy) / 2 )

        deltaZ : Float
        deltaZ =
            0.1

        ( frontList, backList ) =
            points
                |> List.map
                    (\( px, py ) ->
                        let
                            toVertex : Float -> Attributes
                            toVertex z =
                                { position = vec3 (px - centerx) (centery - py) z
                                }
                        in
                        ( toVertex -deltaZ, toVertex deltaZ )
                    )
                |> List.unzip

        triangularMesh : TriangularMesh Attributes
        triangularMesh =
            TriangularMesh.combine
                [ -- Front
                  indexes
                    |> List.concat
                    |> TriangularMesh.indexed (Array.fromList frontList)
                , -- Back
                  indexes
                    |> List.concat
                    |> List.map (\( a_, b, c ) -> ( c, b, a_ ))
                    |> TriangularMesh.indexed (Array.fromList backList)

                -- Side
                , case List.Extra.findIndex ((==) ( 0, 0 )) (List.drop 1 points) of
                    Nothing ->
                        TriangularMesh.strip (cycle frontList) (cycle backList)

                    Just splitIndex ->
                        points
                            |> List.Extra.splitAt (splitIndex + 1)
                            |> (\( before, after ) -> [ before, List.drop 1 after ])
                            |> List.map
                                (\segment ->
                                    segment
                                        |> List.map
                                            (\( px, py ) ->
                                                let
                                                    toVertex : Float -> Attributes
                                                    toVertex z =
                                                        { position = vec3 (px - centerx) (centery - py) z }
                                                in
                                                ( toVertex -deltaZ, toVertex deltaZ )
                                            )
                                        |> List.unzip
                                        |> (\( front, back ) -> TriangularMesh.strip (cycle front) (cycle back))
                                )
                            |> TriangularMesh.combine
                ]
    in
    triangularMesh
        |> TriangularMesh.faceVertices
        |> WebGL.triangles


cycle : List a -> List a
cycle input =
    case input of
        [] ->
            []

        head :: _ ->
            input ++ [ head ]


type Msg
    = Resized Int Int
    | Tick Duration


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { time = Quantity.zero
      , width = Pixels.int 800
      , height = Pixels.int 600
      }
    , Browser.Dom.getViewport
        |> Task.perform (\{ viewport } -> Resized (floor viewport.width) (floor viewport.height))
    )


wordLength : Duration
wordLength =
    Duration.seconds 5


words : List (List (Mesh Attributes))
words =
    [ [ i, s ]
    , [ n, e, v, e, r ]
    , [ e, a, s, y ]
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resized width height ->
            ( { model | width = Pixels.int width, height = Pixels.int height }
            , Cmd.none
            )

        Tick delta ->
            ( { model
                | time =
                    Quantity.plus model.time delta
                        |> Quantity.fractionalModBy
                            (Quantity.multiplyBy (toFloat <| List.length words) wordLength)
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    let
        baseAzimuth : Angle
        baseAzimuth =
            model.time
                |> Quantity.at
                    (Angle.degrees 180
                        |> Quantity.per wordLength
                    )

        index : Int
        index =
            Quantity.ratio model.time wordLength
                |> floor
                |> modBy (List.length words)

        ( azimuth, letters ) =
            ( if modBy 2 index == 0 then
                baseAzimuth
                    |> Quantity.plus (Angle.degrees 180)

              else
                baseAzimuth
                    |> Quantity.plus (Angle.degrees 0)
            , words
                |> List.Extra.getAt index
                |> Maybe.withDefault []
            )

        uniforms : Int -> Uniforms
        uniforms meshIndex =
            { model =
                Matrix4.makeTranslate3
                    (4 * (toFloat meshIndex - (toFloat letterCount - 1) / 2))
                    0
                    0
                    |> Matrix4.rotate
                        (Angle.inRadians azimuth)
                        (vec3 0 1 0)
            , perspective = perspective
            }

        perspective : Mat4
        perspective =
            let
                distance : number
                distance =
                    10
            in
            Matrix4.mul
                (Matrix4.makePerspective
                    30
                    (Quantity.ratio
                        (Quantity.toFloatQuantity model.width)
                        (Quantity.toFloatQuantity model.height)
                    )
                    0.001
                    100
                )
                (Matrix4.makeLookAt
                    (vec3 (distance * Angle.cos azimuth) 0 (distance * Angle.sin azimuth))
                    (vec3 0 0 0)
                    (vec3 0 1 0)
                )

        letterCount : Int
        letterCount =
            List.length letters

        entities : List Entity
        entities =
            letters
                |> List.indexedMap
                    (\meshIndex mesh ->
                        WebGL.entity vertexShader
                            fragmentShader
                            mesh
                            (uniforms meshIndex)
                    )
    in
    WebGL.toHtml
        [ Html.Attributes.style "width" "100vw"
        , Html.Attributes.style "height" "100vh"
        , Html.Attributes.style "background" "black"
        , Html.Attributes.width <| 2 * Pixels.inPixels model.width
        , Html.Attributes.height <| 2 * Pixels.inPixels model.height
        ]
        entities


vertexShader : Shader Attributes Uniforms Varyings
vertexShader =
    [glsl|
        attribute vec3 position;
        uniform mat4 model;
        uniform mat4 perspective;

        void main () {
            gl_Position = perspective * model * vec4(position, 1.0);
        }
    |]


fragmentShader : Shader {} Uniforms Varyings
fragmentShader =
    [glsl|
        precision mediump float;

        void main () {
            gl_FragColor = vec4(.2,.2,.7,1);
        }
    |]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize Resized
        , Browser.Events.onAnimationFrameDelta
            (\delta ->
                delta
                    |> Duration.milliseconds
                    |> Tick
            )
        ]
