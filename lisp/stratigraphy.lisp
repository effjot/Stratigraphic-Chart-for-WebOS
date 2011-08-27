;;;; stratigraphy.lisp -- generate International Stratigraphic Chart HTML and CSS

;;;; This is all a bit ad-hoc because it's basically just various datasets thrown together...

;;;; TODO:
;;;; base-accuracy "awaiting ratified" in description!


(defpackage :stratigraphy
  (:use :common-lisp :json))

(in-package :stratigraphy)


;;;; output file setup

(defparameter *html-file* "../data/isc2009.html")
(defparameter *json-file* "../data/stratigraphic-data.js")

(defparameter *print-gssp* nil)

(defparameter *html-base-age-class* "age")

(defparameter *html-preamble*
  "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
   <html><head>
    <title>International Stratigraphic Chart 2009</title>
    <meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">
    <link rel=\"stylesheet\" href=\"stratigraphy.css\">
    <meta name=\"viewport\" content=\"width=320\">
   </head>
   <body>")

(defparameter *html-table-head*
  (concatenate 'string
     "<table>
       <thead>
        <tr>
          <th>Eonothem</th>
          <th>Erathem</th>
          <th colspan=\"2\">System</th>
          <th>Series</th>
          <th>Stage</th>
          <th>begins</th>"
     (if *print-gssp* "<th>GSSP/</th>" "")
     "  </tr>
        <tr>
          <th>Eon</th>
          <th>Era</th>
          <th colspan=\"2\">Period</th>
          <th>Epoch</th>
          <th>Age</th>
          <th>(Ma b.p.)</th>"
     (if *print-gssp* "<th>GSSA</th>" "")
       "</tr>
      </thead>
      <tbody>"))

(defparameter *html-postscript* "</tbody></table></body></html>")

(defparameter *json-preamble* "function StratigraphicData() { this.details =")

(defparameter *json-postscript* "}")


;;;;
;;;; Stratigraphy data
;;;;

;;; Hierarchy

(defparameter *ranks*
  '(:age :epoch :subperiod :period :era :eon))

(defparameter *hierarchy*
  '((hadean)

    (archean
     (eoarchean paleoarchean mesoarchean neoarchean))

    (proterozoic
     ((paleoproterozoic
       (siderian rhyacian orosirian statherian))
      (mesoproterozoic
       (calymmian ectasian stenian))
      (neoproterozoic
       (tonian cryogenian ediacaran))))

    (phanerozoic
     ((paleozoic
       ((cambrian
         ((terreneuvian
           (fortunian cambrian-stage-2))
          (cambrian-series-2
           (cambrian-stage-3 cambrian-stage-4))
          (cambrian-series-3
           (cambrian-stage-5 drumian guzhangian))
          (furongian
           (paibian cambrian-stage-9 cambrian-stage-10))))
        (ordovician
         ((lower-ordovician
           (tremadocian floian))
          (middle-ordovician
           (dapingian darriwilian))
          (upper-ordovician
           (sandbian katian hirnantian))))
        (silurian
         ((llandovery
           (rhuddanian aeronian telychian))
          (wenlock
           (sheinwoodian homerian))
          (ludlow
           (gorstian ludfordian))
          (pridoli)))
        (devonian
         ((lower-devonian
           (lochkovian pragian emsian))
          (middle-devonian
           (eifelian givetian))
          (upper-devonian
           (frasnian famennian))))
        (carboniferous
         ((:subperiod mississippian
           ((lower-mississippian
             (tournaisian))
            (middle-mississippian
             (visean))
            (upper-mississippian
             (serpukhovian))))
          (:subperiod pennsylvanian
           ((lower-pennsylvanian
             (bashkirian))
            (middle-pennsylvanian
             (moscovian))
            (upper-pennsylvanian
             (kasimovian gzhelian))))))
        (permian
         ((cisuralian
           (asselian sakmarian artinskian kungurian))
          (guadalupian
           (roadian wordian capitanian))
          (lopingian
           (wuchiaphingian changhsingian))))))
      (mesozoic
       ((triassic
         ((lower-triassic
           (induan olenekian))
          (middle-triassic
           (anisian ladinian))
          (upper-triassic
           (carnian norian rhaetian))))
        (jurassic
         ((lower-jurassic
           (hettangian sinemurian pliensbachian toarcian))
          (middle-jurassic
           (aalenian bajocian bathonian callovian))
          (upper-jurassic
           (oxfordian kimmeridgian tithonian))))
        (cretaceous
         ((lower-cretaceous
           (berriasian valanginian hauterivian
                       barremian aptian albian))
          (upper-cretaceous
           (cenomanian turonian coniacian santonian
                       campanian maastrichtian))))))
      (cenozoic
       ((paleogene
         ((paleocene
           (danian selandian thanetian))
          (eocene
           (ypresian lutetian bartonian priabonian))
          (oligocene
           (rupelian chattian))))
        (neogene
         ((miocene
           (aquitanian burdigalian langhian serravallian
                       tortonian messinian))
          (pliocene (zanclean piacenzian))))
        (quaternary
         ((pleistocene
           (gelasian calabrian ionian upper-pleistocene))
          (holocene))))))))
"Hierarchic tree of stratigraphic units.  Unit names are represented as symbols,
followed by a list of corresponding sub-units: (unit (list of sub-units)).
Carboniferous subperiods have to be prefixed by the :subperiod keyword.")


;;; Colour styles

(defparameter *css*
  '((phanerozoic (154 217 221))
    (proterozoic (247 53 99))
    (archean (240 4 127))
    (hadean (174 2 126) 'bright)

    (cenozoic (242 249 29))
    (mesozoic (103 197 202))
    (paleozoic (153 192 141))

    (neoproterozoic (254 179 66))
    (mesoproterozoic (253 180 98))
    (paleoproterozoic (247 67 112))
    (neoarchean (249 155 193))
    (mesoarchean (247 104 169))
    (paleoarchean (244 68 159))
    (eoarchean (218 3 127))

    (quaternary (249 249 127))
    (neogene (255 230 25))
    (paleogene (253 154 82))

    (cretaceous (127 198 78))
    (jurassic (52 178 201))
    (triassic (129 43 146) 'bright)

    (permian (240 64 40))
    (carboniferous (103 165 153) 'bright)
    (pennsylvanian (153 194 181))        ;subperiod
    (mississippian (141 143 102) bright) ;subperiod
    (devonian (203 140 55))
    (silurian (179 225 182))
    (ordovician (0 146 112) 'bright)
    (cambrian (127 160 86) 'bright)

    (ediacaran (254 217 106))
    (cryogenian (254 204 92))
    (tonian (254 191 78))
    (stenian (254 217 154))
    (ectasian (253 204 138))
    (calymmian (253 192 122))
    (statherian (248 117 167))
    (orosirian (247 104 152))
    (rhyacian (247 91 137))
    (siderian (247 79 124))

    (holocene (254 242 236))
    (pleistocene (255 242 174))

    (pliocene (255 255 153))
    (miocene (255 255 0))
    (oligocene (253 192 122))
    (eocene (253 180 108))
    (paleocene (253 167 95))

    (upper-cretaceous (166 216 74))
    (lower-cretaceous (140 205 87))

    (upper-jurassic (179 227 239))
    (middle-jurassic (128 207 216))
    (lower-jurassic ( 66 174 208))

    (upper-triassic (189 140 195))
    (middle-triassic (177 104 177))
    (lower-triassic (125  57 153) bright)

    (lopingian (251 167 148))
    (guadalupian (251 116 92))
    (cisuralian (239 88 69))

    (upper-pennsylvanian (191 208 186))
    (middle-pennsylvanian (166 199 183))
    (lower-pennsylvanian (140 190 180))

    (upper-mississippian (179 190 108))
    (middle-mississippian (153 180 108))
    (lower-mississippian (128 171 108))

    (upper-devonian (241 225 157))
    (middle-devonian (241 200 104))
    (lower-devonian (229 172 77))

    (pridoli (230 245 225))
    (ludlow (191 230 207))
    (wenlock (179 225 194))
    (llandovery (153 215 179))

    (upper-ordovician (127 202 147))
    (middle-ordovician (77 180 126))
    (lower-ordovician (26 157 111) bright)

    (furongian (179 224 149))
    (cambrian-series-3 (166 207 134))
    (cambrian-series-2 (153 192 120))
    (terreneuvian (140 176 108))

    (upper-pleistocene (255 242 211))
    (ionian (255 242 199))
    (calabrian (255 242 186))
    (gelasian (255 237 179))

    (piacenzian (255 255 191))
    (zanclean (255 255 179))

    (messinian (255 255 115))
    (tortonian (255 255 102))
    (serravallian (255 255  89))
    (langhian (255 255  77))
    (burdigalian (255 255  65))
    (aquitanian (255 255  51))

    (chattian (254 230 170))
    (rupelian (254 217 154))

    (priabonian (253 205 161))
    (bartonian (253 192 145))
    (lutetian (252 180 130))
    (ypresian (252 167 115))

    (thanetian (253 191 111))
    (selandian (254 191 101))
    (danian (253 180  98))

    (maastrichtian (242 250 140))
    (campanian (230 244 127))
    (santonian (217 237 116))
    (coniacian (204 233 104))
    (turonian (191 227 93))
    (cenomanian (179 222 83))

    (albian (204 234 151))
    (aptian (191 228 138))
    (barremian (179 223 127))
    (hauterivian (166 217 117))
    (valanginian (153 211 106))
    (berriasian (140 205 96))

    (tithonian (217 241 247))
    (kimmeridgian (204 236 244))
    (oxfordian (191 231 241))
    (callovian (191 231 229))
    (bathonian (179 226 227))
    (bajocian (166 221 224))
    (aalenian (154 217 221))
    (toarcian (153 206 227))
    (pliensbachian (128 197 221))
    (sinemurian (103 188 216))
    (hettangian ( 78 179 211))

    (rhaetian (227 185 219))
    (norian (214 170 211))
    (carnian (201 155 203))
    (ladinian (201 131 191))
    (anisian (188 117 183))
    (olenekian (176  81 165) bright)
    (induan (164  70 159) bright)

    (changhsingian (252 192 178))
    (wuchiaphingian (252 180 162))
    (capitanian (251 154 133))
    (wordian (251 141 118))
    (roadian (251 128 105))
    (kungurian (227 135 118))
    (artinskian (227 135 104))
    (sakmarian (227 111 92))
    (asselian (227 99 80))

    (gzhelian (204 212 199))
    (kasimovian (191 208 197))
    (moscovian (199 203 185))
    (bashkirian (153 194 181))
    (serpukhovian (191 194 107))
    (visean (166 185 108))
    (tournaisian (140 176 108))

    (famennian (242 237 197))
    (frasnian (242 237 173))
    (givetian (241 225 133))
    (eifelian (241 213 118))
    (emsian (229 208 117))
    (pragian (229 196 104))
    (lochkovian (229 183 90))

    (ludfordian (217 240 223))
    (gorstian (204 236 221))
    (homerian (204 235 209))
    (sheinwoodian (191 230 195))
    (telychian (191 230 207))
    (aeronian (179 225 194))
    (rhuddanian (166 220 181))
    (hirnantian (166 219 171))
    (katian (153 214 159))
    (sandbian (140 208 148))
    (darriwilian (116 198 156))
    (dapingian (102 192 146))
    (floian (65 176 135))
    (tremadocian (51 169 126))

    (cambrian-stage-10 (230 245 201))
    (cambrian-stage-9 (217 240 187))
    (paibian (204 235 174))
    (guzhangian (204 223 170))
    (drumian (191 217 157))
    (cambrian-stage-5 (179 212 146))
    (cambrian-stage-4 (179 202 142))
    (cambrian-stage-3 (166 197 131))
    (cambrian-stage-2 (166 186 128))
    (fortunian (153 181 117)))
"Colour styles for stratigraphic units.  List of: unit's symbol,
list of R, G, B values, optional 'bright for bright text colour.")


;;; Information (base age, GSSP, short info text)

(defparameter *data*
  '((phanerozoic "Phanero&shy;zoic" nil nil nil "Literally, &ldquo;visible animal live&rdquo;, as larger lifeforms with hard shells and skeletons developed and left visible fossils.")
    (cenozoic "Cenozoic" nil nil nil "Literally, the &ldquo;new animal life&rdquo;, meaning the dominance of mammals in this era.")
    (quaternary "Quaternary")

    (holocene "Holocene" 0.0117 (digits 4) gssp "Geological present, warm time; post-/interglacial. Has no stages/ages.")
    (pleistocene "Pleistocene" nil nil nil "Generally colder climate compared to Neogene and Paleogene, with several large glaciations alternating with warmer interglacials.")
    (upper-pleistocene "Upper Pleistocene" 0.126 (digits 3) nil "Contains the Eemian interglacial and the Last Glaciation (Weichselian (N. Europe) / Würm (Alps) / Wisconsian (N. America)).")
    (ionian "Ionian" 0.781 (digits 3) nil "Proposed name.  Contains the Elsterian (N. Europe) / Mindel (Alps) / Kansan (N. America) glacial, Holsteinian (N. Europe) / Yarmouthian (N. America) interglacial, and Saalian (N. Europe) / Riss (Alps) / Illinoian (N. America) glacial.")
    (calabrian "Calabrian" 1.806  (digits 3) gssp)
    (gelasian "Gelasian" 2.588 (digits 3) gssp "Has been moved from Pliocene to Pleistocene in 2009.")

    (neogene "Neogene" nil nil nil "Younger part of the former Tertiary period.")
    (pliocene "Pliocene")
    (piacenzian "Piacenzian" 3.600 (digits 3) gssp)
    (zanclean "Zanclean" 5.322 (digits 3) gssp)
    (miocene "Miocene")
    (messinian "Messinian" 7.246 (digits 3) gssp)
    (tortonian "Tortonian" 11.608 (digits 3) gssp)
    (serravallian "Serravallian" 13.82 (digits 2) gssp)
    (langhian "Langhian" 15.97 (digits 2))
    (burdigalian "Burdigalian" 20.43 (digits 2))
    (aquitanian "Aquitanian" 23.03 (digits 2) gssp)

    (paleogene "Paleogene" nil nil nil "Older part of the former Tertiary period.")
    (oligocene "Oligocene")
    (chattian "Chattian" 28.4 0.1)
    (rupelian "Rupelian" 33.9 0.1 gssp)
    (eocene "Eocene")
    (priabonian "Priabonian" 37.2  0.1)
    (bartonian "Bartonian" 40.4  0.2)
    (lutetian "Lutetian" 48.6  0.2)
    (ypresian "Ypresian" 55.8  0.2 gssp)
    (paleocene "Paleocene")
    (thanetian "Thanetian" 58.7  0.2 gssp)
    (selandian "Selandian" 61.1 approx gssp)
    (danian "Danian" 65.5  0.3 gssp)

    (mesozoic "Meso&shy;zoic" nil nil nil "Means &ldquo;middle animal life&rdquo;, the era of dinosaurs and other reptiles (but first mammals were also present).  At the beginning of the Mesozoic, the Pangea supercontinent was still intact; breakup happened during the second half.")
    (cretaceous "Cretaceous")
    (upper-cretaceous "Upper Cretaceous")
    (maastrichtian "Maastrichtian" 70.6  0.6 gssp)
    (campanian "Campanian" 83.5  0.7)
    (santonian "Santonian" 85.8  0.7)
    (coniacian "Coniacian" 88.6 approx)
    (turonian "Turonian" 93.6  0.8 gssp)
    (cenomanian "Cenomanian" 99.6  0.9 gssp)
    (lower-cretaceous "Lower Cretaceous")
    (albian "Albian" 112.0  1.0)
    (aptian "Aptian" 125.0  1.0)
    (barremian "Barremian" 130.0  1.5)
    (hauterivian "Hauterivian" 133.9 approx)
    (valanginian "Valanginian" 140.2  3.0)
    (berriasian "Berriasian" 145.5  4.0)

    (jurassic "Jurassic")
    (upper-jurassic "Upper Jurassic")
    (tithonian "Tithonian" 150.8  4.0)
    (kimmeridgian "Kimmeridgian" 155.6 approx)
    (oxfordian "Oxfordian" 161.2  4.0)
    (middle-jurassic "Middle Jurassic")
    (callovian "Callovian" 164.7  4.0)
    (bathonian "Bathonian" 167.7  4.0 gssp)
    (bajocian "Bajocian" 171.6  3.0 gssp)
    (aalenian "Aalenian" 175.6  2.0 gssp)
    (lower-jurassic "Lower Jurassic")
    (toarcian "Toarcian" 183.0  1.5)
    (pliensbachian "Pliens&shy;bachian" 189.6  1.5 gssp)
    (sinemurian "Sinemurian" 196.5  1.0 gssp)
    (hettangian "Hettangian" 199.6  0.6)

    (triassic "Triassic" nil nil nil "Means &ldquo;triplet&rdquo;: named after its appearance in Germany &ndash; coloured sandstones, shelly limestones, shales.")
    (upper-triassic "Upper Triassic")
    (rhaetian "Rhaetian" 203.6  1.5)
    (norian "Norian" 216.5  2.0)
    (carnian "Carnian" 228.7 approx gssp)
    (middle-triassic "Middle Triassic")
    (ladinian "Ladinian" 237.0  2.0 gssp)
    (anisian "Anisian" 245.9 approx)
    (lower-triassic "Lower Triassic")
    (olenekian "Olenekian" 249.5 approx)
    (induan "Induan" 251.0 0.4 gssp)

    (paleozoic "Paleo&shy;zoic" nil nil nil "Literally, the &ldquo;old animal life&rdquo;. Invertebrates appeared at the beginning of this era, vertebrates developed later on: fish, amphibians and reptiles.  A large number of small continents successively joined to form the Pangea supercontinent.")
    (permian "Permian")
    (lopingian "Lopingian")
    (changhsingian "Chang&shy;hsingian" 253.8 0.7 gssp)
    (wuchiaphingian "Wuchia&shy;pingian" 260.4 0.7 gssp)
    (guadalupian "Guada&shy;lupian")
    (capitanian "Capitanian" 265.8 0.7 gssp)
    (wordian "Wordian" 268.0 0.7 gssp)
    (roadian "Roadian" 270.6 0.7)
    (cisuralian "Cisuralian")
    (kungurian "Kungurian" 275.6 0.7)
    (artinskian "Artinskian" 284.4 0.7)
    (sakmarian "Sakmarian" 294.6 0.8)
    (asselian "Asselian" 299.0 0.8 gssp)

    (carboniferous "Carboni&shy;ferous")
    (pennsylvanian "Pennsyl&shy;vanian")
    (upper-pennsylvanian "Upper Pennsyl&shy;vanian")
    (gzhelian "Gzhelian" 303.4 0.9)
    (kasimovian "Kasimovian" 307.2 1.0)
    (middle-pennsylvanian "Middle Pennsyl&shy;vanian")
    (moscovian "Moscovian" 311.7 1.1)
    (lower-pennsylvanian "Lower Pennsyl&shy;vanian")
    (bashkirian "Bashkirian" 318.1 1.3 gssp)
    (mississippian "Missis&shy;sippian")
    (upper-mississippian "Upper Missis&shy;sippian")
    (serpukhovian "Serpukhovian" 328.3 1.6)
    (middle-mississippian "Middle Missis&shy;sippian")
    (visean "Visean" 345.3 2.1 gssp)
    (lower-mississippian "Lower Missis&shy;sippian")
    (tournaisian "Tournaisian" 359.2 2.5 gssp)

    (devonian "Devonian")
    (upper-devonian "Upper Devonian")
    (famennian "Famennian" 374.5 2.6 gssp)
    (frasnian "Frasnian" 374.5 2.6 gssp)
    (middle-devonian "Middle Devonian")
    (givetian "Givetian" 391.8 2.7 gssp)
    (eifelian "Eifelian" 397.5 2.7 gssp)
    (lower-devonian "Lower Devonian")
    (emsian "Emsian" 407.0 2.8 gssp)
    (pragian "Pragian" 411.2 2.8 gssp)
    (lochkovian "Lochkovian" 416.0 2.8 gssp)

    (silurian "Silurian")
    (pridoli "Pridoli" 418.7 2.7 gssp "Has no stages/ages.")
    (ludlow "Ludlow")
    (ludfordian "Ludfordian" 421.3 2.6 gssp)
    (gorstian "Gorstian" 422.9 2.5 gssp)
    (wenlock "Wenlock")
    (homerian "Homerian" 426.2 2.4 gssp)
    (sheinwoodian "Shein&shy;woodian" 428.2 2.3 gssp)
    (llandovery "Llandovery")
    (telychian "Telychian" 436.0 1.9 gssp)
    (aeronian "Aeronian" 439.0 1.8 gssp)
    (rhuddanian "Rhuddanian" 443.7 1.5 gssp)

    (ordovician "Ordovician")
    (upper-ordovician "Upper Ordovician")
    (hirnantian "Hirnantian" 445.6 1.5 gssp)
    (katian "Katian" 455.8 1.6 gssp)
    (sandbian "Sandbian" 460.9 1.6 gssp)
    (middle-ordovician "Middle Ordovician")
    (darriwilian "Darriwilian" 468.1 1.6 gssp)
    (dapingian "Dapingian" 471.8 1.6 gssp)
    (lower-ordovician "Lower Ordovician")
    (floian "Floian" 478.6 1.7 gssp)
    (tremadocian "Tremadocian" 488.3 1.7 gssp)

    (cambrian "Cambrian")
    (furongian "Furongian")
    (cambrian-stage-10 "Cambrian Stage 10" 492 approx-not-ratfd)
    (cambrian-stage-9 "Cambrian Stage 9" 496 approx-not-ratfd)
    (paibian "Paibian" 499 coarse-approx gssp)
    (cambrian-series-3 "Cambrian Series 3")
    (guzhangian "Guzhangian" 503 coarse-approx gssp)
    (drumian "Drumian" 506.5 approx gssp)
    (cambrian-stage-5 "Cambrian Stage 5" 510 approx-not-ratfd)
    (cambrian-series-2 "Cambrian Series 2")
    (cambrian-stage-4 "Cambrian Stage 4" 515 approx-not-ratfd)
    (cambrian-stage-3 "Cambrian Stage 3" 521 approx-not-ratfd)
    (terreneuvian "Terreneuvian")
    (cambrian-stage-2 "Cambrian Stage 2" 528 approx-not-ratfd)
    (fortunian "Fortunian" 542.0 1.0 gssp)

    (proterozoic "Protero&shy;zoic" nil nil nil "Literally, &ldquo;early animal life&rdquo; &ndash; animals started to develop. Because those animals had mostly no shells or skeleton, there are few fossils.  This eon is characterised by an oxygen atmosphere.")
    (neoproterozoic "Neopro&shy;terozoic")
    (ediacaran "Ediacaran" 635 coarse-approx gssp)
    (cryogenian "Cryogenian" 850 coarse gssa)
    (tonian "Tonian" 1000 coarse gssa)

    (mesoproterozoic "Mesopro&shy;terozoic")
    (stenian "Stenian" 1200 coarse gssa)
    (ectasian "Ectasian" 1400 coarse gssa )
    (calymmian "Calymmian" 1600 coarse gssa)

    (paleoproterozoic "Paleopro&shy;terozoic")
    (statherian "Statherian" 1800 coarse gssa)
    (orosirian "Orosirian" 2050 coarse gssa)
    (rhyacian "Rhyacian" 2300 coarse gssa)
    (siderian "Siderian" 2500 coarse gssa)

    (archean "Archean" nil nil nil "The name means &ldquo;beginning&rdquo;: the first single-cell organisms (bacteria etc.) lived in the oceans.")
    (neoarchean "Neo&shy;archean" 2800 coarse gssa)
    (mesoarchean "Meso&shy;archean" 3200 coarse gssa)
    (paleoarchean "Paleo&shy;archean" 3600 coarse gssa)
    (eoarchean "Eo&shy;archean" 4000 coarse)

    (hadean "Hadean (informal)" 4600 coarse-approx nil "The &ldquo;pre-geologic&rdquo; eon. Formation of Earth (4.54 Ga &plusmn; 1%) and Moon (4.527 &plusmn; 0.010 Ga).  Development of the first stable crust.")))



;;;;
;;;; Class and methods for stratigraphic data
;;;;

(defclass strat-unit ()
  ((id             :initarg :id)
   name
   (rank           :accessor rank)
   (color          :initarg :color)
   (bright-text    :initarg :bright-text :initform nil)
   (base-megayears :initarg :base-megayears :initform nil)
   (base-accuracy  :initarg :base-accuracy :initform nil)
   (defined-by     :initform nil)
   (text           :initform nil)
   (children       :initform nil :accessor children)))


(defmethod older ((x strat-unit) (y strat-unit))
  (let ((x-base (slot-value x 'base-megayears))
        (y-base (slot-value y 'base-megayears)))
    (cond
      ((null x-base) y)
      ((null y-base) x)
      (t (if (> x-base y-base) x y)))))

(defun get-base-age (unit)
  (cond
    ((null unit) (cons 0 'undefined))
    ((null (slot-value unit 'base-megayears))
     (get-base-age (first (children unit))))
    (t
     (cons (slot-value unit 'base-megayears)
           (slot-value unit 'base-accuracy)))))


;;; Tree functions

(defgeneric collect-leaves (tree))

(defmethod collect-leaves ((tree list))
  (let ((leaves ()))
    (labels ((walk (tree)
               (cond
                 ((null tree))
                 ((atom tree) (push tree leaves))
                 (t (walk (car tree))
                    (walk (cdr tree))))))
      (walk tree))
    (nreverse leaves)))

(defmethod collect-leaves ((unit strat-unit))
  (let ((leaves ()))
    (labels ((walk (tree)
               (cond
                 ((null tree))
                 ((and (atom tree) (children tree)) ; has children
                  (walk (children tree)))
                 ((atom tree)           ; no children
                  (push tree leaves))
                 (t (walk (car tree))   ; is a list of units
                    (walk (cdr tree))))))
      (walk unit))
    leaves))




;;;;
;;;; HTML output and pretty-printing (on-screen)
;;;;

;;; Ranks

(defparameter *prettyprinted-ranks*
  '(:age       "Stage/Age"
    :epoch     "Series/Epoch"
    :subperiod "Subperiod/Subsystem"
    :period    "System/Period"
    :era       "Erathem/Era"
    :eon       "Eonothem/Eon"))

(defun pretty-print-rank (rank stream)
  (format stream (getf *prettyprinted-ranks* rank)))


;;; Age / base of unit

(defun print-base-megayears-nicely (age accuracy stream)
  (cond
    ((null age)            (format stream ""))
    ((null accuracy)       (format stream "~F" age))
    ((numberp accuracy)    (format stream "~F &plusmn; ~F" age accuracy))
;    ((eq accuracy 'approx) (format stream "&asymp;~F" age))
    ((eq accuracy 'approx) (format stream "≈~F" age))
    (t                     (error "Malformed base age: ~S, ~S" age accuracy))))

(defun pretty-print-base (base-age stream &optional (age-unit "Ma"))
  (let ((age      (car base-age))
        (accuracy (cdr base-age)))
    (cond
      ((null age)
       (format stream ""))
      ((null accuracy)
       (format stream "~F~@[ ~A~]" age age-unit))
      ((numberp accuracy)
       (format stream "~F ± ~F~@[ ~A~]" age accuracy age-unit))
      ((and (consp accuracy) (eq (car accuracy) 'digits))
       (format stream
               (concatenate 'string "~," (write-to-string (cadr accuracy))
                            "F~@[ ~A~]")
               age age-unit))
      ((eq accuracy 'approx)
       (format stream "≈~F~@[ ~A~]" age age-unit))
      ((eq accuracy 'coarse)
       (format stream "~D~@[ ~A~]" age age-unit))
      ((eq accuracy 'coarse-approx)
       (format stream "≈~D~@[ ~A~]" age age-unit))
      ((eq accuracy 'approx-not-ratfd)
       (format stream "≈~D~@[ ~A~]*" age age-unit))
      ((eq accuracy 'undefined)
       (format stream "(undefined)"))
      (t
       (error "Malformed base age: ~S, ~S" age accuracy)))))


;;; Stratigraphic unit object

(defmethod print-object ((obj strat-unit) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    ;; for debugging: all information
    (with-slots (name rank color bright-text
                      base-megayears base-accuracy) obj
      (format
       stream
       "~S ~A: begins ~F ± ~A; color: ~A~:[~; with bright text~]"
       rank name base-megayears base-accuracy color bright-text))
  ;    (format stream "~A" (slot-value obj 'id))
))


;;; HTML table output

(defun print-html-td-unit (unit stream &optional rowspan colspan print-link)
  (with-slots (id name) unit
    (let ((id-lower-case (string-downcase (symbol-name id))))
      (format stream
              "~&<td ~@[rowspan=\"~D\" ~]~@[colspan=\"~D\" ~]~
              ~@[onclick=\"location.href='~A'\" ~]class=\"~A rule\"~
              >~A</td>"
              rowspan colspan
              (when print-link id-lower-case)
              id-lower-case name))))

(defun print-html-td-age-gssp (unit stream &optional (print-gssp *print-gssp*))
  (with-slots (base-megayears base-accuracy defined-by) unit
    (format stream
            "~&<td><div class=\"~A\">~A</div></td>"
            *html-base-age-class*
            (pretty-print-base (cons base-megayears base-accuracy) 
                               nil nil))
    (when print-gssp
      (format stream
              "~&<td><div class=\"~A\">~@[~A~]</div></td>"
              *html-base-age-class*
              defined-by))))


(defgeneric print-html-tree (obj stream &optional print-link))

(defmethod print-html-tree ((obj strat-unit) stream
                            &optional (print-link t))
  (labels
      ((walk (obj stream tr-printed)
         (with-slots (id name rank base-megayears base-accuracy
                         defined-by children) obj

           (unless tr-printed (format stream "~&<tr>"))

           (cond
             ((children obj)            ; has children
              (print-html-td-unit obj stream
                                  (length (collect-leaves obj)) ; rows
                                  (if (and ; cols (period&subperiods)
                                       (eq rank :period)
                                       (not (member :subperiod
                                                    (children obj)
                                                    :key #'rank)))
                                      2 nil)
                                  print-link)
              (let ((ch (reverse (children obj))))
                (walk (car ch) stream t) ; print first child without <tr>
                (dolist (c (cdr ch))     ; print rest with leading <tr>
                  (walk c stream nil))))

             (t                         ; is leaf
              (print-html-td-unit obj stream nil (if (eq rank :period) 2 nil)
                                  print-link)
              (unless (eq rank :age)  ; some units have no stages/ages
                (when (member rank (list :eon :era)) ; skip to age column
                  (format stream "~&<td class=\"rule\"></td>"))
                (dotimes (i (position rank (remove :subperiod *ranks*)))
                  (format stream "~&<td class=\"rule\"></td>")))
              (print-html-td-age-gssp obj stream)
              (format stream "~&</tr>"))))))
    (walk obj stream nil)))

(defun print-html-strat-table (list-of-top-rank-units stream)
  (format stream "~&~A~%~A" *html-preamble* *html-table-head*)
  (dolist (unit list-of-top-rank-units)
    (print-html-tree unit stream t))
  (format stream "~&~A~%" *html-postscript*))




;;;;
;;;; Set up data structure and write files
;;;;

;;; Generate flat alist of unit objects from hierarchy

;; set up alist and helper functions

(defparameter *units*
  (mapcar (lambda (id)
            (format t "~&id: ~s~%" id)
            (cons id
                  (make-instance 'strat-unit :id id)))
          (remove-if #'keywordp (collect-leaves *hierarchy*)))
"Flat alist of unit objects.  Key is ID; use GET-UNIT function to get the
corresponding object.")

(defun get-unit (name &optional (db *units*))
  "Get unit object by its ID symbol."
  (cdr (assoc name db)))

(defparameter *eons*
  (nreverse (mapcar (lambda (u) (get-unit (car u))) *hierarchy*)))

;; (defun get-oldest-unit (unit-hierarchy &optional (db *units*))
;;   "Get oldest sub-unit (i.e. base) of a higher-rank unit UNIT-HIERARCHY tree."
;;   (reduce #'older
;;           (mapcar (lambda (u)
;;                     (get-unit u db))
;;                   (collect-leaves unit-hierarchy))))

;; fill in stratigraphic information and color styles

(dolist (entry *data*)
  (let ((unit (get-unit (first entry))))
    (setf (slot-value unit 'name) (second entry))
    (when (third entry)
      (setf (slot-value unit 'base-megayears) (third entry))
      (when (fourth entry)
        (setf (slot-value unit 'base-accuracy) (fourth entry)))
      (setf (slot-value unit 'defined-by) (fifth entry)))
    (when (sixth entry)
      (format t "text: ~A~%" (sixth entry))
      (setf (slot-value unit 'text) (sixth entry)))))

(dolist (entry *css*)
  (let ((unit (get-unit (first entry))))
    (setf (slot-value unit 'color) (second entry))
    (when (third entry)
      (setf (slot-value unit 'bright-text) t))))

;; fill in sub-units in objects' CHILDREN slots

(defun assign-children-from-hierarchy (hier ranks)
  (labels ((collect-direct-children (tree)
             (mapcar (lambda (x)
                       (cond
                         ((atom x) x)
                         ((keywordp (car x)) (cadr x))
                         (t (car x))))
                     tree))
           (walk (tagged-tree ranks)
             (let* ((subperiod (eq (car tagged-tree) :subperiod))
                    (tree (if subperiod (cdr tagged-tree) tagged-tree))
                    (node (car tree))
                    (child-nodes (cadr tree)))
               (cond

                 ((null tree))

                 ((every #'atom tree)   ; no children, just assign rank
                  (format t "~&~s [~a]#" tree ranks)
                  (mapcar (lambda (x)
                            (setf (slot-value (get-unit x) 'rank)
                                  (first ranks)))
                          tree))

                 ((and (atom node)      ; node with children
                       (consp child-nodes))
                  (format t "~&~s [~a, ~a]: " node ranks subperiod)
                  (let ((unit (get-unit node))
                        (ch (collect-direct-children child-nodes)))
                    (format t "~s" ch)
                    (setf (children unit)
                          (mapcar #'get-unit ch))
                    (setf (slot-value unit 'rank)
                          (if subperiod :subperiod (first ranks))))
                  (walk child-nodes     ; work on children
                        (if subperiod ranks (cdr ranks))))

                 ((every #'listp tree)  ; list of nodes with same rank
                  (format t "~&LISTS: ~s,~%~s~%" (car tree) (cdr tree))
                  (walk (car tree) ranks)
                  (walk (cdr tree) ranks))

                 (t (error "shouldn't happen"))))))

    (walk hier ranks)))

(assign-children-from-hierarchy *hierarchy*
                                (reverse (remove :subperiod *ranks*)))


;;; Write HTML file

(with-open-file (s *html-file* :direction :output :if-exists :supersede)
  (print-html-strat-table *eons* s))


;;; Write JSON file

(defun alist-of-unit-data (unit)
  "Generate alist of unit's information (for JSON export)."
  (with-slots (id name rank base-megayears base-accuracy defined-by color bright-text text)
      unit
    (let ((id-string (string-downcase (symbol-name id))))
      (cons id-string
       (pairlis
        '(:id :name :rank :base :defined :rgb :bright :text)
        (list id-string name
              (pretty-print-rank rank nil)
              (pretty-print-base (get-base-age unit) nil)
              (if defined-by
                  (symbol-name defined-by)
                  "none")
              (list (first color) (second color) (third color))
              (if bright-text t)
              (concatenate
               'string
               (if (eq base-accuracy 'approx-not-ratfd)
                   "*Age informal, awaiting ratified definition. "
                   "")
               (if text text ""))))))))

(with-open-file (stream *json-file*
                        :direction :output :if-exists :supersede
                        :external-format :utf-8 )
  (format stream "~&~A~%" *json-preamble*)
  (json:encode-json (mapcar (lambda (u) (alist-of-unit-data (get-unit u)))
                            (remove-if #'keywordp
                                       (collect-leaves *hierarchy*)))
                    stream)
  (format stream "~&~A~%" *json-postscript*))

