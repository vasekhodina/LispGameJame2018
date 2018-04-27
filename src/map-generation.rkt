#lang racket
(require noise thing "point.rkt")
(provide get-tile)
(struct level-definition (tile-gen npcs items))
(define levels (make-hasheq))
(define current-depth (make-parameter 0))
; Generate a new level if one does not exist
(define (get-level depth)
    (unless (hash-has-key? levels depth)
        (define level (make-hash))
        (hash-set! level 'seed (random))
        (hash-set! level 'npcs '())
        (hash-set! level 'gen (level-definition surface nothing nothing))
        (hash-set! levels depth level))
    (hash-ref levels depth))

(define (get-tile x y)
  (define current-level (get-level (current-depth)))
  (define seed (hash-ref current-level 'seed))

  ; If the tile doesn't already exist, generate it
  (unless (hash-has-key? current-level (pt x y))
    ; Get the new tile
    ; Copy the tile here so that they don't share state
    (define new-tile
      (let ([base-tile ((level-definition-tile-gen (hash-ref current-level 'gen)) seed x y)])
        (make-thing base-tile)))
    (hash-set! current-level (pt x y) new-tile))

  ; Return the tile (newly generated or not)
  (hash-ref current-level (pt x y)))

; The surface level with grass, water, and trees
(define (surface seed x y)
  (define water? (> (simplex (* 0.1 x) seed      (* 0.1 y)) 0.5))
  (define tree?  (> (simplex seed      (* 0.1 x) (* 0.1 y)) 0.5))
  (cond
    [water? (make-thing water)]
    [tree?  (make-thing tree)]
    [else    (make-thing grass)]))

; ===== Basic tile definitions =====

(define-thing tile
  [character "space"]
  [color "black"]
  [items '()]
  [lighting 'dark]    ; Dark: Invisible; Fog: Only show tile, not NPC or item; Lit: Everything
  [walkable #f]       ; Can the player walk on this tile?
  [solid #f])         ; Does this tile block light?

(define-thing empty tile
  [walkable #t])

(define-thing grass tile
  [character "."]
  [color "brown"]
  [walkable #t])

(define-thing wall tile
  [solid #t]
  [character "#"]
  [color "white"])

(define-thing water tile
  [character "~"]
  [color "blue"])

(define-thing tree tile
  [solid #t]
  [character "♠"]
  [color "green"])

(define (nothing seed x y) #f)