module Meshes exposing (..)

import Array
import List.Extra
import Math.Vector3 exposing (vec3)
import TriangularMesh exposing (TriangularMesh)
import Types exposing (Attributes)
import WebGL exposing (Mesh)


words : List (List (Mesh Attributes))
words =
    [ [ i, s ]
    , [ n, e, v, e, r ]
    , [ e, a, s, y ]
    ]


quad : number -> number -> number -> number -> List ( number, number, number )
quad pa pb pc pd =
    [ ( pa, pb, pd ), ( pd, pb, pc ) ]


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
                                { apos = vec3 (px - centerx) (centery - py) z
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
                                                        { apos = vec3 (px - centerx) (centery - py) z }
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
