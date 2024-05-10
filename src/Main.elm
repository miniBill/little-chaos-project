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
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Meshes
import Pixels exposing (Pixels)
import Quantity exposing (Quantity)
import Task
import TriangularMesh exposing (TriangularMesh)
import Types exposing (Attributes)
import WebGL exposing (Entity, Mesh, Shader)
import WebGL.Settings.DepthTest as DepthTest


type alias Flags =
    {}


type alias Model =
    { time : Duration
    , width : Quantity Int Pixels
    , height : Quantity Int Pixels
    }


type alias Uniforms =
    { model : Mat4
    , perspective : Mat4
    }


type alias Varyings =
    { vpos : Vec3 }


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


wordDuration : Duration
wordDuration =
    Duration.seconds 3


wordsCount : Int
wordsCount =
    List.length Meshes.words


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resized width height ->
            if height * 16 // 9 < width then
                ( { model
                    | width = Pixels.int (height * 16 // 9)
                    , height = Pixels.int height
                  }
                , Cmd.none
                )

            else
                ( { model
                    | width = Pixels.int width
                    , height = Pixels.int (width * 9 // 16)
                  }
                , Cmd.none
                )

        Tick delta ->
            ( { model
                | time =
                    Quantity.plus model.time delta
                        |> Quantity.fractionalModBy
                            (Quantity.multiplyBy (toFloat wordsCount) wordDuration)
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    let
        index : Int
        index =
            Quantity.ratio model.time wordDuration
                |> floor
                |> modBy wordsCount

        letters : List (Mesh Attributes)
        letters =
            Meshes.words
                |> List.Extra.getAt index
                |> Maybe.withDefault []

        uniforms : Int -> Uniforms
        uniforms meshIndex =
            { model =
                Matrix4.makeTranslate3
                    (4 * (toFloat meshIndex - (toFloat letterCount - 1) / 2))
                    0
                    0
            , perspective = perspective
            }

        perspective : Mat4
        perspective =
            makePerspective model

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

        background : Entity
        background =
            WebGL.entityWith [ DepthTest.always { write = False, near = -1, far = 1 } ]
                backgroundVertexShader
                backgroundFragmentShader
                backgroundMesh
                {}

        px : Quantity Int Pixels -> String
        px quantity =
            String.fromInt (Pixels.inPixels quantity) ++ "px"
    in
    WebGL.toHtml
        [ Html.Attributes.style "width" (px model.width)
        , Html.Attributes.style "height" (px model.height)
        , Html.Attributes.style "background" "black"
        , Html.Attributes.width <| Pixels.inPixels model.width
        , Html.Attributes.height <| Pixels.inPixels model.height
        ]
        (background :: entities)


backgroundMesh : Mesh { apos : Vec2 }
backgroundMesh =
    WebGL.triangleFan
        [ { apos = vec2 -1 -1 }
        , { apos = vec2 1 -1 }
        , { apos = vec2 1 1 }
        , { apos = vec2 -1 1 }
        ]


makePerspective : Model -> Mat4
makePerspective model =
    let
        index : Int
        index =
            Quantity.ratio model.time wordDuration
                |> floor
                |> modBy wordsCount

        distance : number
        distance =
            25

        baseAzimuth : Angle
        baseAzimuth =
            model.time
                |> Quantity.at
                    (Angle.degrees 180
                        |> Quantity.per wordDuration
                    )

        azimuth : Angle
        azimuth =
            if modBy 2 index == 0 then
                baseAzimuth
                    |> Quantity.plus (Angle.degrees 0)

            else
                baseAzimuth
                    |> Quantity.plus (Angle.degrees 180)
    in
    Matrix4.mul
        (Matrix4.makePerspective
            30
            (Quantity.ratio
                (Quantity.toFloatQuantity model.width)
                (Quantity.toFloatQuantity model.height)
            )
            0.01
            100
        )
        (Matrix4.makeLookAt
            (vec3 (distance * Angle.cos azimuth) 0 (distance * Angle.sin azimuth))
            (vec3 0 0 0)
            (vec3 0 1 0)
        )


vertexShader : Shader Attributes Uniforms Varyings
vertexShader =
    [glsl|
        attribute vec3 apos;
        uniform mat4 model;
        uniform mat4 perspective;
        varying vec3 vpos;

        void main () {
            vpos = apos;
            gl_Position = perspective * model * vec4(apos, 1.0);
        }
    |]


fragmentShader : Shader {} Uniforms Varyings
fragmentShader =
    [glsl|
        precision mediump float;

        varying vec3 vpos;

        // https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
        // BEGIN
        float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
        vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
        vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

        float noise(vec3 p){
            vec3 a = floor(p);
            vec3 d = p - a;
            d = d * d * (3.0 - 2.0 * d);

            vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
            vec4 k1 = perm(b.xyxy);
            vec4 k2 = perm(k1.xyxy + b.zzww);

            vec4 c = k2 + a.zzzz;
            vec4 k3 = perm(c);
            vec4 k4 = perm(c + 1.0);

            vec4 o1 = fract(k3 * (1.0 / 41.0));
            vec4 o2 = fract(k4 * (1.0 / 41.0));

            vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
            vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

            return o4.y * d.y + o4.x * (1.0 - d.y);
        }
        // END

        void main () {
            gl_FragColor = vec4(.2,.2,.7,1) * noise(319. * vpos);
        }
    |]


backgroundVertexShader : Shader { apos : Vec2 } {} { vpos : Vec2 }
backgroundVertexShader =
    [glsl|
        attribute vec2 apos;
        varying vec2 vpos;

        void main () {
            vpos = apos;
            gl_Position = vec4(apos, 0, 1);
        }
    |]


backgroundFragmentShader : Shader {} {} { vpos : Vec2 }
backgroundFragmentShader =
    [glsl|
        precision mediump float;

        varying vec2 vpos;

        // https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
        // BEGIN
        float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
        vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
        vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

        float noise(vec3 p){
            vec3 a = floor(p);
            vec3 d = p - a;
            d = d * d * (3.0 - 2.0 * d);

            vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
            vec4 k1 = perm(b.xyxy);
            vec4 k2 = perm(k1.xyxy + b.zzww);

            vec4 c = k2 + a.zzzz;
            vec4 k3 = perm(c);
            vec4 k4 = perm(c + 1.0);

            vec4 o1 = fract(k3 * (1.0 / 41.0));
            vec4 o2 = fract(k4 * (1.0 / 41.0));

            vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
            vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

            return o4.y * d.y + o4.x * (1.0 - d.y);
        }
        // END

        void main () {
            vec2 npos = 20000. * vec2(16, 9) * vpos;
            gl_FragColor = vec4(.7,.7,.9,1) * (noise(vec3(npos, 0)) > 0.9 ? 1. : 0.);
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
