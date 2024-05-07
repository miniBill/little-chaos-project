module Main exposing (Flags, Model, Msg, main)

import Angle exposing (Angle)
import Array exposing (Array)
import Browser
import Browser.Dom
import Browser.Events
import Camera3d exposing (Camera3d)
import Color
import Direction3d
import Duration exposing (Duration)
import Html exposing (Html)
import Illuminance
import Length exposing (Meters)
import List.Extra
import Pixels exposing (Pixels)
import Point3d exposing (Point3d)
import Quantity exposing (Quantity)
import Scene3d exposing (Entity)
import Scene3d.Light as Light
import Scene3d.Material as Material
import Scene3d.Mesh as Mesh
import Task
import TriangularMesh exposing (TriangularMesh)
import Vector3d
import Viewpoint3d


type alias Flags =
    {}


type alias Model =
    { time : Duration
    , width : Quantity Int Pixels
    , height : Quantity Int Pixels
    }


quad : number -> number -> number -> number -> List ( number, number, number )
quad a b c d =
    [ ( a, b, d ), ( d, b, c ) ]


i : Entity coordinates
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


s : Entity coordinates
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


n : Entity coordinates
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
        , [ ( 2, 9, 3 ), ( 3, 9, 8 ) ]
        , quad 4 7 6 5
        ]


e : Entity coordinates
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


v : Entity coordinates
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


extrude : List ( Float, Float ) -> List (List ( Int, Int, Int )) -> Entity coordinates
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
                                (\( x, y ) ( mx, my ) ->
                                    ( step x mx, step y my )
                                )
                                ( ( headx, headx ), ( heady, heady ) )
                                tail
                    in
                    ( (minx + maxx) / 2, (miny + maxy) / 2 )

        frontList : List (Point3d Meters coordinates)
        frontList =
            points
                |> List.map (\( x, y ) -> Point3d.centimeters (x - centerx) -0.5 (centery - y))

        frontArray : Array (Point3d Meters coordinates)
        frontArray =
            frontList
                |> Array.fromList

        backList : List (Point3d Meters coordinates)
        backList =
            points
                |> List.map (\( x, y ) -> Point3d.centimeters (x - centerx) 0.5 (centery - y))

        backArray : Array (Point3d Meters coordinates)
        backArray =
            backList
                |> Array.fromList

        triangularMesh : TriangularMesh (Point3d Meters coordinates)
        triangularMesh =
            TriangularMesh.combine
                [ -- Front
                  indexes
                    |> List.concat
                    |> TriangularMesh.indexed frontArray
                , -- Back
                  indexes
                    |> List.concat
                    |> List.map (\( a, b, c ) -> ( c, b, a ))
                    |> TriangularMesh.indexed backArray

                -- Side
                , TriangularMesh.strip (cycle frontList) (cycle backList)
                ]

        mesh : Mesh.Uniform coordinates
        mesh =
            Mesh.indexedFacets triangularMesh
                |> Mesh.cullBackFaces

        shadow : Mesh.Shadow coordinates
        shadow =
            Mesh.shadow mesh
    in
    Scene3d.meshWithShadow
        (Material.nonmetal
            { baseColor = Color.blue
            , roughness = 0.5
            }
        )
        mesh
        shadow


cycle : List (Point3d Meters coordinates) -> List (Point3d Meters coordinates)
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
    Duration.seconds 3


words : List (List (Entity coordinates))
words =
    let
        a =
            s

        y =
            a

        r =
            s
    in
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

        camera : Camera3d Meters coordinates
        camera =
            Camera3d.perspective
                { viewpoint =
                    Viewpoint3d.orbitZ
                        { focalPoint = Point3d.origin
                        , azimuth = azimuth
                        , distance = Length.centimeters 40
                        , elevation = Angle.degrees 0
                        }
                , verticalFieldOfView = Angle.degrees 30
                }
    in
    Scene3d.custom
        { dimensions = ( model.width, model.height )
        , entities = row letters
        , clipDepth = Length.centimeters 3
        , background = Scene3d.backgroundColor Color.black
        , camera = camera
        , lights =
            Scene3d.twoLights
                (Light.directional (Light.castsShadows True)
                    { chromaticity = Light.sunlight
                    , intensity = Illuminance.lux 80000
                    , direction = Direction3d.xyZ (Angle.degrees 30) (Angle.degrees -45)
                    }
                )
                (Light.ambient
                    { chromaticity = Light.sunlight
                    , intensity = Illuminance.lux 20000
                    }
                )
        , toneMapping = Scene3d.hableFilmicToneMapping
        , antialiasing = Scene3d.supersampling 2
        , exposure = Scene3d.exposureValue 15
        , whiteBalance = Light.sunlight
        }


row : List (Entity coordinates) -> List (Entity coordinates)
row entities =
    let
        count : Int
        count =
            List.length entities
    in
    entities
        |> List.indexedMap
            (\index entity ->
                entity
                    |> Scene3d.translateBy (Vector3d.centimeters (4 * (toFloat index - (toFloat count - 1) / 2)) 0 0)
            )


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
