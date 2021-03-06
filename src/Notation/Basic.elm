module Notation.Basic
    exposing
        ( staffLine
        , staff5Line
        , barlineThick
        , barlineThin
        , clef
        , beamUpper
        , beamLower
        , noteHead
        , stem
        , augmentationDot
        , flat
        , sharp
        , natural
        , doubleFlat
        , doubleSharp
        , flag8th
        , flag16th
        , Clef(..)
        , NoteHead(..)
        , Direction(..)
        , slur
        )

{-| Draw kinds of music notations.

This module only draw raw components near coordinate (0, 0). Transformation & positioning should be controlled outside.
Each component specifies the detailed formation of the component.
All length parameters are the measurements expressed in staff spaces.

# Components
@docs staffLine, staff5Line, barlineThick, barlineThin, clef, beamUpper, beamLower, noteHead, stem, augmentationDot, flat, sharp, natural, doubleFlat, doubleSharp, flag8th, flag16th, Clef, NoteHead, Direction, slur
-}

import Svg exposing (..)
import Svg.Lazy exposing (..)
import Svg.Attributes exposing (..)
import Notation.Variables as Var
import Notation.FontMeta exposing (..)


type alias Point =
    ( Float, Float )


{-| Draw a single staff line from (0, 0) to (length , 0). The thickness of the line are equally divided by the x-axis.
-}
staffLine : Float -> List (Attribute msg) -> Svg msg
staffLine length attr =
    lazy2 (\length attr -> line ([ x1 "0", y1 "0", x2 (toString length), y2 "0", stroke Var.color, strokeWidth (toString engravingDefaults.staffLineThickness) ] ++ attr) []) length attr


{-| Draw a standard five-line stave, where the top line lies on the x-axis from (0, 0) to (length , 0).
-}
staff5Line : Float -> List (Attribute msg) -> Svg msg
staff5Line length attr =
    lazy2 (\length attr -> g attr <| List.map (\n -> staffLine length [ y1 (toString n), y2 (toString n) ]) [ 0, 1, 2, 3, 4 ]) length attr


{-| Draw a thick barline from (0, 0) to (0, length) on the y-axis.
-}
barlineThick : Float -> List (Attribute msg) -> Svg msg
barlineThick length attr =
    lazy2 (\length attr -> line ([ x1 "0", y1 "0", x2 "0", y2 (toString length), stroke Var.color, strokeWidth (toString engravingDefaults.thickBarlineThickness) ] ++ attr) []) length attr


{-| Draw a thin barline from (0, 0) to (0, length) on the y-axis.
-}
barlineThin : Float -> List (Attribute msg) -> Svg msg
barlineThin length attr =
    lazy2 (\length attr -> line ([ x1 "0", y1 "0", x2 "0", y2 (toString length), stroke Var.color, strokeWidth (toString engravingDefaults.thinBarlineThickness) ] ++ attr) []) length attr


{-| Draw a celf, which takes the x-axis as the placement line on a stave and left ended at y-axis
-}
clef : Clef -> List (Attribute msg) -> Svg msg
clef c attr =
    lazy2 (\c attr -> glyph (stringOfClef c) attr) c attr


{-| Draw a beam, with the left-top corner (0, 0), and right-top corner (x, y).
    left-bottom and right-bottom corners will be adjusted to satisfy beamThickness.
-}
beamUpper : Point -> List (Attribute msg) -> Svg msg
beamUpper ( x, y ) attr =
    let
        pts =
            String.join " "
                [ "0,0"
                , pointAsString ( x, y )
                , pointAsString ( x, y + beamOffset ( x, y ) )
                , pointAsString ( 0, beamOffset ( x, y ) )
                ]
    in
        lazy2 (\( x, y ) attr -> polygon ([ fill Var.color, strokeWidth "0", points pts ] ++ attr) []) ( x, y ) attr


{-| Draw a beam, with the left-bottom corner (0, 0), and right-bottom corner (x, y).
    left-top and right-top corners will be adjusted to satisfy beamThickness.
-}
beamLower : Point -> List (Attribute msg) -> Svg msg
beamLower ( x, y ) attr =
    let
        pts =
            String.join " "
                [ "0,0"
                , pointAsString ( x, y )
                , pointAsString ( x, y - beamOffset ( x, y ) )
                , pointAsString ( 0, 0 - beamOffset ( x, y ) )
                ]
    in
        lazy2 (\( x, y ) attr -> polygon ([ fill Var.color, strokeWidth "0", points pts ] ++ attr) []) ( x, y ) attr


{-| Draw a note head, vertically centered by x-axis and left ended at y-axis
-}
noteHead : NoteHead -> List (Attribute msg) -> Svg msg
noteHead value attr =
    lazy2 (\value attr -> glyph (stringOfNoteValue value) attr) value attr


{-| Draw a stem line from (0, 0) to (0, length). The left end is attached to y-axis.
-}
stem : Float -> List (Attribute msg) -> Svg msg
stem length attr =
    lazy2 (\length attr -> rect ([ x "0", y "0", width (toString engravingDefaults.stemThickness), height (toString length), strokeWidth "0", fill Var.color ] ++ attr) []) length attr


{-| Draw a augmentation dot centered at (0, 0).
-}
augmentationDot : List (Attribute msg) -> Svg msg
augmentationDot attr =
    lazy (\attr -> glyph "\xE1E7" attr) attr


{-| Draw a flat accidental around (0, 0), as it is matching a noteHead on the x-axis.
-}
flat : List (Attribute msg) -> Svg msg
flat attr =
    lazy (\attr -> glyph "\xE260" attr) attr


{-| Draw a sharp accidental around (0, 0), as it is matching a noteHead on the x-axis.
-}
sharp : List (Attribute msg) -> Svg msg
sharp attr =
    lazy (\attr -> glyph "\xE262" attr) attr


{-| Draw a natural accidental around (0, 0), as it is matching a noteHead on the x-axis.
-}
natural : List (Attribute msg) -> Svg msg
natural attr =
    lazy (\attr -> glyph "\xE261" attr) attr


{-| Draw a double sharp accidental around (0, 0), as it is matching a noteHead on the x-axis.
-}
doubleSharp : List (Attribute msg) -> Svg msg
doubleSharp attr =
    lazy (\attr -> glyph "\xE263" attr) attr


{-| Draw a double flat accidental around (0, 0), as it is matching a noteHead on the x-axis.
-}
doubleFlat : List (Attribute msg) -> Svg msg
doubleFlat attr =
    lazy (\attr -> glyph "\xE264" attr) attr


{-| Draw an 8th flag for stem around (0, 0).
-}
flag8th : Direction -> List (Attribute msg) -> Svg msg
flag8th direction attr =
    lazy2
        (\direction attr ->
            glyph
                (case direction of
                    Up ->
                        "\xE240"

                    Down ->
                        "\xE241"
                )
                attr
        )
        direction
        attr


{-| Draw an 16th flag for stem around (0, 0).
-}
flag16th : Direction -> List (Attribute msg) -> Svg msg
flag16th direction attr =
    lazy2
        (\direction attr ->
            glyph
                (case direction of
                    Up ->
                        "\xE242"

                    Down ->
                        "\xE243"
                )
                attr
        )
        direction
        attr


{-| -}
type Direction
    = Up
    | Down


{-| -}
type Clef
    = GClef
    | FClef


{-| -}
type NoteHead
    = Whole
    | Half
    | Black


{-| Draw cubic bézier curve from (0,0) to p3, the thickness is equally added to both side of the original zero-width curve
-}
slur : Point -> Point -> Point -> List (Attribute msg) -> Svg msg
slur p1 p2 p3 attr =
    lazy
        (\( ( x1, y1 ), ( x2, y2 ), ( x3, y3 ), attr ) ->
            let
                gap =
                    (engravingDefaults.slurMidpointThickness - engravingDefaults.slurEndpointThickness) * 4 / 3

                dx =
                    x1 - x2

                dy =
                    y1 - y2

                ( x1a, y1a, x2a, y2a, x1b, y1b, x2b, y2b ) =
                    if dx == 0 then
                        ( x1 - gap / 2, y1, x2 - gap / 2, y2, x1 + gap / 2, y1, x2 + gap / 2, y2 )
                    else if dy == 0 then
                        ( x1, y1 - gap / 2, x2, y2 - gap / 2, x1, y1 + gap / 2, x2, y2 + gap / 2 )
                    else
                        let
                            ratio =
                                dy / dx

                            distanceY =
                                gap / sqrt (ratio * ratio + 1)

                            distanceX =
                                ratio * distanceY
                        in
                            ( x1 - distanceX / 2, y1 - distanceY / 2, x2 - distanceX / 2, y2 - distanceY / 2, x1 + distanceX / 2, y1 + distanceY / 2, x2 + distanceX / 2, y2 + distanceY / 2 )

                spaceJoin f1 f2 =
                    String.join " " [ toString f1, toString f2 ]

                commaJoin f1 f2 f3 f4 f5 f6 =
                    String.join ", " [ spaceJoin f1 f2, spaceJoin f3 f4, spaceJoin f5 f6 ]

                pathAttr =
                    "M0 0 C " ++ commaJoin x1a y1a x2a y2a x3 y3 ++ " C " ++ commaJoin x2b y2b x1b y1b 0 0 ++ " Z"
            in
                Svg.path ([ d pathAttr, fill "black", strokeWidth (toString engravingDefaults.slurEndpointThickness), strokeLinejoin "round", stroke Var.color ] ++ attr) []
        )
        ( p1, p2, p3, attr )



-- private


beamOffset : ( Float, Float ) -> Float
beamOffset ( x, y ) =
    sqrt (x ^ 2 + y ^ 2) / x * engravingDefaults.beamThickness


pointAsString : Point -> String
pointAsString ( x, y ) =
    String.join "," [ toString x, toString y ]


stringOfClef : Clef -> String
stringOfClef c =
    case c of
        GClef ->
            "\xE050"

        FClef ->
            "\xE062"


stringOfNoteValue : NoteHead -> String
stringOfNoteValue value =
    case value of
        Whole ->
            "\xE0A2"

        Half ->
            "\xE0A3"

        Black ->
            "\xE0A4"


{-| Draw glyph
-}
glyph : String -> List (Attribute msg) -> Svg msg
glyph str attr =
    lazy2 (\str attr -> text_ ([ fontFamily "Bravura", fontSize (toString Var.fontSize), color Var.color ] ++ attr) [ text str ]) str attr
